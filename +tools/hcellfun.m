function varargout = hcellfun(varargin)
% tools.hcellfun(f,X)
%
%     Xはcell配列
%
%     fは関数
%     a = f(X{k})
%
%     このとき以下のようにすると，
%     A = tools.vcellfun(f,X)
%
%     Aは
%     A = [f(X{1}), f(X{2}); ..., f(X{end})]; 
%     と対応している．
%     
    varargout_ = cell(nargout, 1);
    [varargout_{:}] = cellfun(varargin{:}, 'UniformOutput', false);
    varargout = tools.cellfun(@(o) horzcat(o{:}), varargout_);
end
