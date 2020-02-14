function ge_list = CS6380_ge_list(index1,index2,nx)
% CS6380_ge_list - gets grid elements between two grid indexes
% On input:
%     index1 (int): linear index of launch location into grid
%     index2 (int): linear index of landing location into grid
%     nx (int): number of grid rows
% On output:
%     ge_list (1xn vector): list of grid indexes covered by line segment
%                           from index1 grid element to index2 grid element
% Call:
%     ge_list = CS6380_ge_list(3,14,4);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

r1 = mod(index1-1,nx) + 1;
c1 = (index1-r1)/nx + 1;
r2 = mod(index2-1,nx) + 1;
c2 = (index2-r2)/nx + 1;
[rows,cols] = MNDAS_line_between([r1,c1],[r2,c2]);
num_pts = length(rows);
ge_list = zeros(1,num_pts);
for p = 1:num_pts
    ge_list(p) = (cols(p)-1)*nx + rows(p);
end
