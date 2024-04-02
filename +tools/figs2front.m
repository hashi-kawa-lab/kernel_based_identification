function figs2front()
    % すべてのfigureを最前面に表示する関数
    
    % すべてのfigureのハンドルを取得
    allFigures = findall(0, 'Type', 'figure');
    
    % 各figureを最前面に移動
    for i = 1:numel(allFigures)
        figure(allFigures(i));
    end
end
