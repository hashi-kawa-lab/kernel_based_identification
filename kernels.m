classdef kernels

    methods(Static)
        
        function Kdc = DC(degree, options)
            arguments
                degree
                options.alpha = 0.9
                options.beta = 100
                options.rho = 0.9
            end
            DCalpha = options.alpha;
            DCbeta = options.beta;
            DCrho = options.rho;
            Kdc = zeros(degree);
            for i = 1:1:degree
                for j = 1:1:degree
                    Kdc(i,j) = DCbeta*DCalpha^((i+j)/2)*DCrho^abs(i-j);
                end
            end
        end
    end

end