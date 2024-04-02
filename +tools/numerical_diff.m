function [varargout] = numerical_diff(varargin)
varargout = cell(nargout, 1);
[varargout{:}] = tools.test_diff(varargin{:});
end

