function varargout = varrayfun(varargin)
% tools.varrayfun(f,X)
%
%     Xは配列
%
%     fは関数
%     a = f(X(k))
%
%     このとき以下のようにすると，
%     A = tools.varrayfun(f,X)
%
%     Aは
%     A = [f(X(1)); f(X(2)); ...; f(X(end))]; 
%     と対応している．
%     
    varargout_ = cell(nargout, 1);
    [varargout_{:}] = arrayfun(varargin{:}, 'UniformOutput', false);
    varargout = tools.cellfun(@(o) vertcat(o{:}), varargout_);
end
