function [out] = struct2parameter(S)
out = tools.vcellfun(@(f) {f; S.(f)}, fieldnames(S));
if isempty(out)
    out = {};
end
end

