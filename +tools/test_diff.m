function [v, dv, dv_num] = test_diff(func, theta, h, pararell)
if nargout == 3
[v, dv] = func(theta);
else
    v = func(theta);
end
if nargin < 3 || isempty(h)
    h = 1e-8;
end
if nargin < 4
    if islogical(h)
        pararell = h;
        h = 1e-8;
    else
        pararell  = false;
    end
end
dv_num = zeros(size(v, 1), size(v,2), numel(theta));
tools.parfor_progress(numel(theta));
if pararell
    parfor itr = 1:numel(theta)
        theta1 = theta;
        theta1(itr) = theta1(itr) + h;
        v1 = func(theta1);
        dv_num(:, :, itr) = (v1-v)/h;
        tools.parfor_progress();
    end
else
    for itr = 1:numel(theta)
        theta1 = theta;
        theta1(itr) = theta1(itr) + h;
        v1 = func(theta1);
        dv_num(:, :, itr) = (v1-v)/h;
        tools.parfor_progress();
    end
end
tools.parfor_progress(0);
dv_num = squeeze(dv_num);

if nargout ~= 3
dv = dv_num;
end

end

