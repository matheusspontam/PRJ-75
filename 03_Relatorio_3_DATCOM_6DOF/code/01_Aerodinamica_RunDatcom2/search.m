function out = search(token, fid, varargin)
while true
    line = fgetl(fid);
    if ~ischar(line)
        error('Token not found: %s', token);
    end
    idx = strfind(line, token);
    if ~isempty(idx)
        if nargin > 2
            out = line;
        else
            col = idx(1) + length(token);
            while col <= length(line) && isempty(regexp(line(col), '[0-9+\-.]', 'once'))
                col = col + 1;
            end
            out.linha = line;
            out.coluna = col;
        end
        return;
    end
end
end
