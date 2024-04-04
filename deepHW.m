classdef deepHW < handle

    properties
        lgraph
        output_name
        fir_names
        alpha_names
        kernels
        net_trained = []
    end

    methods

        function obj = deepHW(n_input, options)
            arguments
                n_input (1,1) double {mustBeInteger}
                options.min_length (1,1) double {mustBeInteger} = 1
            end
            lgraph = layerGraph();
            templayer = sequenceInputLayer(n_input,"MinLength", options.min_length, "Name", "Input");
            obj.lgraph = addLayers(lgraph, templayer);
            obj.output_name = "Input";
            obj.fir_names = {};
            obj.alpha_names = {};
            obj.kernels = {};
        end

        function names = get_names(obj)
            names = tools.arrayfun(@(l) l.Name, obj.lgraph.Layers);
        end

        function tempLayer = add_layer(obj, tempLayer, options)
            arguments
                obj
                tempLayer
                options.connection_name = obj.output_name
                options.output_name = tempLayer(end).Name
            end

            names = obj.get_names();
            for i = 1:length(tempLayer)
                if ismember(tempLayer(i).Name, names)
                    name_org = tempLayer(i).Name;
                    j = 1;
                    name = strcat(name_org, num2str(j));
                    while ismember(name, names)
                        j = j + 1;
                        name = strcat(name_org, num2str(j));
                    end
                    options.output_name = replace(options.output_name, name_org, name);
                    tempLayer(i).Name = name;
                end
            end

            obj.lgraph = addLayers(obj.lgraph, tempLayer);
            obj.output_name = options.output_name;
            obj.lgraph = connectLayers(obj.lgraph, options.connection_name, tempLayer(1).Name);
        end

        function add_NN(obj, n_hidden, n_out, options)
            arguments
                obj
                n_hidden
                n_out
                options.name = ""
                options.connection_name = obj.output_name
                options.activation_func = @reluLayer
            end

            activation_func = options.activation_func;
            name = options.name;

            tempLayer = [ % 入力層
                fullyConnectedLayer(n_hidden,"Name", strcat("NNin", name))
                activation_func("Name", strcat("activation", name))
                fullyConnectedLayer(n_out,"Name", strcat("NNout", name))];

            obj.add_layer(tempLayer, output_name = tempLayer(end).Name, connection_name = options.connection_name);
        end

        function add_FIR(obj, n_length, n_out, options)
            arguments
                obj
                n_length (1,1) {mustBeInteger}
                n_out (1,1) {mustBeInteger}
                options.name = ""
                options.connection_name = obj.output_name
                options.kernel = kernels.DC(n_length)
            end
            tempLayer = convolution1dLayer(n_length, n_out,...
                "BiasLearnRateFactor", 0,...
                'Stride', 1, 'Padding', 'causal',"Name", strcat("FIR",  options.name));
            fir_layer = obj.add_layer(tempLayer, output_name = tempLayer.Name, connection_name = options.connection_name);

            alphaLayer = convolution1dLayer(n_length, n_out,...
                "BiasLearnRateFactor", 0,...
                'Stride', 1, 'Padding', 'causal',"Name", strcat("alpha",  options.name));
            alpha_layer = obj.add_layer(alphaLayer, output_name = fir_layer(end).Name, connection_name = options.connection_name);

            obj.fir_names = [obj.fir_names; fir_layer.Name];
            obj.alpha_names = [obj.alpha_names; alpha_layer.Name];
            obj.kernels = [obj.kernels; options.kernel];
        end

        function add_FC(obj, n_out, options)
            arguments
                obj
                n_out (1,1) {mustBeInteger}
                options.name = ""
                options.connection_name = obj.output_name
            end

            layer = fullyConnectedLayer(n_out,"Name", strcat("FC", name));
            obj.add_layer(layer, output_name = layer.Name, connection_name = options.connection_name);
        end

        function add_gain(obj, n_out, options)
            arguments
                obj
                n_out (1,1) {mustBeInteger}
                options.name = ""
                options.connection_name = obj.output_name
            end

            layer = fullyConnectedLayer(n_out,"Name", strcat("Gain", options.name), "BiasLearnRateFactor", 0);
            obj.add_layer(layer, output_name = layer.Name, connection_name = options.connection_name);
        end

        function train(obj, U, Y, options)
            arguments
                obj
                U
                Y
                options.epochs (1,1) double {mustBeInteger} = 10000
                options.lambda_kernel (1,1) double = 0
                options.lambda_theta_alpha (1,1) double = 0
                options.lambda_mg (1,1) double = 0
                options.use_gpu = true
                options.decay (1,1) double = 0.005
                options.initial_learning_rate (1,1) double = 0.005
            end

            net = dlnetwork(obj.lgraph);
            out_name = obj.output_name;
            fir_index = tools.varrayfun(@(i) find(strcmp(net.Learnables{:, "Layer"}, obj.fir_names{i})&contains(net.Learnables{:, "Parameter"}, "Weights")), 1:numel(obj.fir_names));
            alpha_index = tools.varrayfun(@(i) find(strcmp(net.Learnables{:, "Layer"}, obj.alpha_names{i})&contains(net.Learnables{:, "Parameter"}, "Weights")), 1:numel(obj.alpha_names));
            lambda = [options.lambda_kernel, options.lambda_theta_alpha, options.lambda_mg];
            Kernels = obj.kernels;

            if options.use_gpu
                dlU_train = gpuArray(dlarray(U, 'TC'));
                dlT_train = gpuArray(dlarray(Y, 'TC'));
                for i = 1:numel(Kernels)
                    Kernels{i} = gpuArray(dlarray(Kernels{i}));
                end
            else
                dlU_train = dlarray(U, 'TC');
                dlT_train = dlarray(Y, 'TC');
                for i = 1:numel(Kernels)
                    Kernels{i} = dlarray(Kernels{i});
                end
            end
            

            n = options.epochs;
            ILR = options.initial_learning_rate;
            decay = options.decay;

            % velocity = [];
            epoch = 0;
            iteration = 0;
            % momentum = 0.8;
            averageGrad = [];
            averageSqGrad = [];

            monitor = trainingProgressMonitor(Metrics=["Loss_Kernel","Loss_log10","Loss_RMSE","Kernelterm","theta_alpha","mg_term"], Info=["Epoch","LearnRate","Loss_Kernel","Loss_log10","Loss_RMSE","Kernelterm","theta_alpha","mg_term"], XLabel="Iteration");
            % learnRate = ILR;
            while epoch < n && ~monitor.Stop

                epoch = epoch + 1;
                iteration = iteration + 1;

                % modelLoss function and update the network state.
                [loss,gradients, loss_rmse, Kernelterm,Theta_Alpha,MG_term] = dlfeval(@obj.lossfunc, net, out_name, dlU_train, dlT_train, fir_index, alpha_index, Kernels, lambda);

                learnRate = ILR/(1 + decay*iteration);

                % if mod(epoch, 1000)==0
                %    learnRate = learnRate * 0.8;
                % end
                [net,averageGrad,averageSqGrad] = adamupdate(net,gradients, averageGrad,averageSqGrad,iteration, learnRate);

                if mod(epoch, 10)==0
                    recordMetrics(monitor,iteration,Loss_Kernel=loss,Loss_log10=log10(extractdata(loss)),Loss_RMSE=loss_rmse,Kernelterm=Kernelterm,theta_alpha=Theta_Alpha,mg_term=MG_term);
                    updateInfo(monitor,Epoch=epoch,LearnRate=learnRate,Loss_Kernel=loss,Loss_log10=log10(extractdata(loss)),Loss_RMSE=loss_rmse,Kernelterm=Kernelterm,theta_alpha=Theta_Alpha,mg_term=MG_term);
                    monitor.Progress = 100 * epoch/n;
                end
            end

            obj.net_trained = net;

        end

        function [Fir_params, Alpha_params] = get_fir_parameters(obj)
            names = obj.get_names();
            fir_index = tools.varrayfun(@(i) find(strcmp(names, obj.fir_names{i})), 1:numel(obj.fir_names));
            alpha_index = tools.varrayfun(@(i) find(strcmp(names, obj.alpha_names{i})), 1:numel(obj.alpha_names));
            Fir_params = cell(numel(fir_index), 1);
            Alpha_params = cell(numel(alpha_index), 1);
            for i = 1:numel(fir_index)
                fir_layer = obj.net_trained.Layers(fir_index(i));
                % l = fir_layer.FilterSize;
                fir_params = flipud(fir_layer.Weights);
                alpha_layer = obj.net_trained.Layers(alpha_index(i));
                alpha_params = alpha_layer.Weights;
                K = obj.kernels{i};
                if numel(size(alpha_params)) == 2
                    alpha_params = K*alpha_params;
                else
                    for j = 1:size(alpha_params, 3)
                        alpha_params(:, :, j) = K*alpha_params(:, :, j);
                    end
                end
                Fir_params{i} = fir_params;
                Alpha_params{i} = alpha_params;
            end
            
        end

        function [Sys, Sys_alpha] = get_fir(obj, options)
            arguments
                obj
                options.Ts = []
            end
            [Fir_params, Alpha_params] = obj.get_fir_parameters();
            Sys = tools.cellfun(@(f) params2fir(f, Ts=options.Ts), Fir_params);
            Sys_alpha = tools.cellfun(@(a) params2fir(a, Ts=options.Ts), Alpha_params);
        end


    end

    methods(Static)
        function [loss, gradients, loss_rmse, Kernelterm, Theta_Alpha, MG_term] = lossfunc(net, out_name, X, T, fir_index, alpha_index, Kernels, lambda)
            Kernelterm = 0;
            MG_term = 0;
            Theta_Alpha = 0;

            for i = 1:numel(fir_index)
                weight_fir = net.Learnables(fir_index(i), "Value");
                weight_fir = weight_fir{1, :}{1};
                K = Kernels{i};
                order = size(K, 1);
                weight_fir = reshape(weight_fir, order, []);

                weight_alpha = net.Learnables(alpha_index(i), "Value");
                weight_alpha = weight_alpha{1, :}{1};
                weight_alpha = reshape(weight_alpha, order, []);

                kernelterm = sum((weight_alpha'*K*weight_alpha).*eye(size(weight_alpha,2)),"all");
                Kernelterm = Kernelterm + kernelterm;

                mg_term = sum((1 - sum(weight_fir.^2,1)).^2);
                MG_term = MG_term + mg_term;

                error = flipud(weight_fir) - K * weight_alpha;

                theta_alpha = mean(error.^2,"all");
                Theta_Alpha = Theta_Alpha + theta_alpha;
            end

            Y = forward(net, X, 'Outputs', out_name);
            loss_rmse = mean((T-Y).^2,"all");
            % loss_rmse = rmse(T, Y,"all");
            loss = loss_rmse + lambda(1)*Kernelterm + lambda(2)*Theta_Alpha + lambda(3)*MG_term;
            gradients = dlgradient(loss,net.Learnables);

        end
    end

    

end

function sys = params2fir(params, options)
    arguments
        params
        options.has_feedthrough (1,1) logical = true
        options.Ts = []
    end

    options = tools.struct2parameter(options);

    if numel(size(params))==2
        sys = tools.harrayfun(@(i) params2fir_(params(:, i), options{:}), 1:size(params, 2));
    else
        sys = tools.varrayfun(@(j) tools.harrayfun(@(i) params2fir_(params(i, j), options{:}),...
            1:size(params, 2)), 1:size(params, 3));
    end
end

function sys = params2fir_(params, options)
    arguments
        params
        options.has_feedthrough (1,1) logical = true
        options.Ts = []
    end
    params = params(:)';
    l = length(params);
    if ~options.has_feedthrough
        l = l + 1;
    end
    den = [1, zeros(1, l-1)];
    sys = tf(params, den, options.Ts);
end