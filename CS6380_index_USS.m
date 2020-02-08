function [USS_out,index] = CS6380_index_USS(USS,USS_name)
%

USS_out = USS;

if isempty(USS)
    USS_out(1).name = USS_name;
    USS_out(1).domains = [];
    USS_out(1).flights = [];
    index = 1;
    return
end

num_USS = length(USS);
for u = 1:num_USS
    if strcmp(USS(u).name,USS_name)
        index = u;
        return
    end
end

num_USS = num_USS + 1;
USS_out(num_USS).name = USS_name;
USS_out(num_USS).domains = [];
USS_out(num_USS).flights = [];
index = length(USS_out);
