function v = select_apply(isA, a, b, varargin)
% tools.select_apply(isA, a, b, varargin)
%     isAがtrueだったらa(varargin)を返し，falseだったらb(varargin)を返す
if isA
    v = a(varargin{:});
else
    v = b(varargin{:});
end
end