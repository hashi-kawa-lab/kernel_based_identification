function l = add_vline(h, y, last, varargin)
if nargin < 3
    last = true;
end

hold_state = ishold(h);

hold(h, 'on');
range = ylim(h);
y = y(:)';
yy = [y;y;nan(1,numel(y))];
yy = yy(:);
xx = repmat([range, nan], 1, numel(y))';
b = false;
for itr = 1:numel(varargin)
    if ischar(varargin{itr})
        if strcmpi('linewidth', varargin{itr})
            b =true;
        end
    end
end
if b
    plot(h, yy, xx, varargin{:});
else
    plot(h, yy, xx, varargin{:}, 'linewidth', 1);
end
hold(h, tools.select_value(hold_state, 'on', 'off'));
g = get(h);
l = g.Children(1);
if last
    set(h, 'Children', [g.Children(2:end); g.Children(1)]);
end
end