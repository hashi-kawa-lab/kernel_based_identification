function hash = get_hash(filename)
    afile = tools.absolute_path(filename);
    cmd = strcat("certutil -hashfile """, afile, """ MD5");
    [status, cmdout] = system(cmd);
    if status==0
        out = splitlines(cmdout);
        hash = out{2};
    else
        hash = [];
    end
end