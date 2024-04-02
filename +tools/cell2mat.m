function [mat, nr, nc] = cell2mat(c, nr, nc)

[row, col] = size(c);

Rmat = nan(row, col);
Cmat = nan(row, col);

for i = 1:col
    for j = 1:row
        
        if isnumeric(c{j, i})
            [Rmat(j, i), Cmat(j, i)] = size(c{j, i});
        end
        
    end
end

R = mode(Rmat, 2);
C = mode(Cmat, 1);

if nargin >= 2 && ~isempty(nr)
    R(isnan(R)) = nr(isnan(R));
end

if nargin >= 3 && ~isempty(nc)
    C(isnan(C)) = nc(isnan(C));
end

if any(isnan(R)) || any(isnan(C))
    for i = 1:col
        for j = 1:row
            if ischar(c{j, i}) && contains(c{j, i}, 'eye')
                if isnan(R(j))
                    R(j) = C(i);
                end
                if isnan(C(i))
                    C(i) = R(j);
                end
            end
        end
    end
end


for i = 1:col
    for j = 1:row
        
        if ischar(c{j, i})
            if startsWith(c{j, i}, '-')
                sign = -1;
                c{j, i} = c{j, i}(2:end);
            else
                sign = 1;
            end
            if strcmp(c{j, i}, 'zeros')
                c{j, i} = zeros(R(j), C(i));
            end
            if strcmp(c{j, i}, 'eye')
                c{j, i} = eye(R(j), C(i));
            end
            c{j, i} = c{j, i} * sign;
        end
        
    end
end

mat = cell2mat(c);

nr = R;
nc = C;

end

