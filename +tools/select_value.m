function v = select_value(isA, a, b)
% tools.select_value(isA, a, b)
%     isAがtrueだったらaを返し，falseだったらbを返す
if isA
    v = a;
else
    v = b;
end
end
