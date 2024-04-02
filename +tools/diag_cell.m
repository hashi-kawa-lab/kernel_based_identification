function out = diag_cell(c)
% tools.diag_cell(C)
%
%     Cは<a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/cell.html')">cell</a> 配列
%
%     このとき以下のようにすると，
%     A = tools.diag_cell(C)
%
%     Aは行列となり，Cの要素を対角に配置している．
%     
%     参考 <a href="matlab: web('https://jp.mathworks.com/help/matlab/ref/blkdiag.html')">blkdiag</a> 
out = blkdiag(c{:});

end

