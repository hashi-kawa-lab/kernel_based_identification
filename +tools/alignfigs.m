function alignfigs(rows, columns, margins, paddings)
    arguments
        rows (1,1) double {mustBeInteger, mustBePositive} = 1
        columns (1,1) double {mustBeInteger, mustBePositive} = 1
        margins double {mustBeNumeric, mustBePositive} = 50
        paddings double {mustBeNumeric, mustBePositive} = 5
    end
    
    % 指定された行数と列数に基づいてfigureを整列する関数
    
    % すべてのfigureのハンドルを取得
    allFigures = findall(0, 'Type', 'figure');
    numbers = {allFigures.Number};
    idx = tools.vcellfun(@(c) ~isempty(c), numbers);
    allFigures = allFigures(idx);
    numbers = vertcat(numbers{idx});
    [~, i] = sort(numbers);
    allFigures = allFigures(i);
    % figureの数
    numFigures = numel(allFigures);
    
    % 行数と列数の積がfigureの数より大きい場合、行数と列数を調整
    while rows * columns < numFigures
        if rows < columns
            rows = rows + 1;
        else
            columns = columns + 1;
        end
    end
    r = groot;
    width_screen = r.ScreenSize(3);
    height_screen = r.ScreenSize(4);
    if numel(margins) == 1
        margins = [margins, margins];
    end
    if numel(paddings) == 1
        paddings = [paddings, paddings];
    end
    width = (width_screen - margins(1) * 2 - paddings(1) * (columns - 1)) / columns;
    height = (height_screen - margins(2) * 2 - paddings(2) * (rows - 1)) / rows;
    % figureを整列させる
    k = 1;
    for i = 1:rows
        for j = 1:columns
            fig = allFigures(k);
            x = margins(1) + (j - 1) * (width + paddings(1));
            y = height_screen - margins(2) - height - (i - 1) * (height + paddings(2));
            set(fig, 'OuterPosition', [x, y, width, height]);
            k = k + 1;
            if k > numFigures
                tools.figs2front;
                return;
            end
        end
    end
    tools.figs2front;
end