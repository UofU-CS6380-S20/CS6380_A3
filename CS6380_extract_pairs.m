function [USS_out,pairs] = CS6380_extract_pairs(USS,ge_USS_list)
% CS6380_extract_pairs - get ge-USS pairs
% On input:
%     USS (struct vector): USS info
%      (u).name (string): name of USS
%      (u).domains (1xn vector): grid elements it operates in
%      (u).flights (unused)
% On output:
%     USS_out (struct vector): updated USS info
%     pairs (mx2 array): ge,USS pairs
% Call:
%     [USS,pairs] = CS6380_extract_pairs(USS,mess_data);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

USS_out = USS;
pairs = [];
if isempty(ge_USS_list)
    return
end

num_ge = length(ge_USS_list);
for g = 1:num_ge
    ge_val = ge_USS_list(g).ge;
    g_USS = ge_USS_list(g).USS;
    [num_USS,dummy] = size(g_USS);
    for u = 1:num_USS
        [USS_out,index] = CS6380_index_USS(USS_out,g_USS(u,:));
        pairs = [pairs; ge_val,index];
        USS_out(index).domains = union(USS_out(index).domains,ge_val);
    end
end
