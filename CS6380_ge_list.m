function ge_list = CS6380_ge_list(x1,y1,x2,y2,UTM_grid)
% CS6380_ge_list - gets grid elements between two grid indexes
% On input:
%     x1 (float): x coord for launch location
%     y1 (float): y coord for launch location
%     x2 (float): x coord for landing location
%     y2 (float): y coord for landing location
%     grid (1x6 vector): grid definition
%        [x_min y_min x_max y_max nx ny]
% On output:
%     ge_list (1xn vector): list of grid indexes covered by line segment
%                           from index1 grid element to index2 grid element
% Call:
%     ge_list = CS6380_ge_list(13.6,24.2,35.7,1.2,UTM_grid);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

nx = UTM_grid(5);
index1 = CS6380_grid_index(UTM_grid,x1,y1);
index2 = CS6380_grid_index(UTM_grid,x2,y2);
r1 = mod(index1-1,nx) + 1;
c1 = (index1-r1)/nx + 1;
del1(1) = x1 - floor(x1);
del1(2) = y1 - floor(y1);
r2 = mod(index2-1,nx) + 1;
c2 = (index2-r2)/nx + 1;
del2(1) = x2 - floor(x2);
del2(2) = y2 - floor(y2);
[rows,cols] = CS6380_line_between([r1,c1],del1,[r2,c2],del2);
num_pts = length(rows);
ge_list = zeros(1,num_pts);
for p = 1:num_pts
    ge_list(p) = (cols(p)-1)*nx + rows(p);
end
