function closeall
    all_fig = findall(0, 'type', 'figure');
    close(all_fig);
end