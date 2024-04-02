function varargout = cellfun(varargin)
% tools.cellfun(f,X)
%
%     Xはn×1の<a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/cell.html')">cell</a> 配列
%
%     fは<a href="matlab: web('https://jp.mathworks.com/help/matlab/matlab_prog/support-variable-number-of-outputs.html')">可変長の出力</a>を返す関数
%     [a,b,c] = f(X{k})
%
%     このとき以下のようにすると，
%     [A,B,C] = tools.cellfun(f,X)
%
%     A,B,Cは<a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/cell.html')">cell</a> 配列となり，
%     [A{k}, B{k}, C{k}] = f(X{k})
%     と対応している．
%     
%     参考 <a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/cellfun.html')">cellfun</a> 
    
    varargout = cell(nargout, 1);
    [varargout{:}] = cellfun(varargin{:}, 'UniformOutput', false);

end
