function [val, idx, idx2] = min2(A, varargin)

[val, I] = min(A, [], 'all', 'linear', varargin{:});
[r, c] = size(A);

idx2 = floor(I/r)+1;
idx1 = mod(I, r);
if idx1 == 0
    idx1 = r;
end

if nargout < 3
    idx = [idx1, idx2];
else
    idx = idx1;
end

end

