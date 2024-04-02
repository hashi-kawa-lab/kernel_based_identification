function varargout = arrayfun(varargin)
% tools.arrayfun(f,X)
%
%     Xは配列
%
%     fは関数
%     [a,b,c] = f(X{k})
%
%     このとき以下のようにすると，
%     [A, B, C] = tools.arrayfun(f,X)
%
%     A,B,Cは<a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/cell.html')">cell</a> 配列となり，
%     [A{k}, B{k}, C{k}] = f(X(k))
%     と対応している．
%     
%     参考 <a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/arrayfun.html')">arrayfun</a> 
    varargout = cell(nargout, 1);
    [varargout{:}] = arrayfun(varargin{:}, 'UniformOutput', false);

end
