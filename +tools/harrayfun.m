function varargout = harrayfun(varargin)
% tools.harrayfun(f,X)
%
%     Xは配列
%
%     fは関数
%     arr = f(X(k))
%
%     このとき以下のようにすると，
%     A = tools.harrayfun(f,X)
%
%     Aは行列となり，
%     A = [f(X(1)), f(X(2)); ..., f(X(end))]; 
%     と対応している．
%     
    varargout_ = cell(nargout, 1);
    [varargout_{:}] = arrayfun(varargin{:}, 'UniformOutput', false);
    varargout = tools.cellfun(@(o) horzcat(o{:}), varargout_);
end
