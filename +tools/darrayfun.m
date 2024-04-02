function varargout = darrayfun(varargin)
% tools.darrayfun(f,X)
%
%     Xは配列
%
%     fは関数
%     a = f(X{k})
%     aは行列
%
%     このとき以下のようにすると，
%     A = tools.darrayfun(f,X)
%
%     Aは
%     
%     A = [f(X{1}),0      ,0      ,...;
%          0      ,f(X{2}),0      ,...;
%          0      ,0      ,f(X{3}),...;
%          0,     ,0      ,0      ,...;]
%     のように対角に結果を配置した行列となる．
out = cell(nargout, 1);

[out{:}] = tools.arrayfun(varargin{:});
varargout = tools.cellfun(@(c) blkdiag(c{:}), out);

end