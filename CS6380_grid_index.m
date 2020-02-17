function index = CS6380_grid_index(UTM_grid,x,y)
% CS6380_grid_index - linear grid index for grid element containing [x,y]'
% On input:
%     grid (1x6 vector): grid definition
%         [x_min y_min x_max y_max nx ny]
%     x (float): x value in grid
%     y (float): y value in grid
% On output:
%     index (int): linear index of grid element
% Call:
%     index = CS6380_grid_index(grid,30.2,22.6);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

index = 0;

x_min = UTM_grid(1);
y_min = UTM_grid(2);
x_max = UTM_grid(3);
y_max = UTM_grid(4);
nx = UTM_grid(5);
ny = UTM_grid(6);

x_d = x_max - x_min;
y_d = y_max - y_min;
x_step = x_d/nx;
y_step = y_d/ny;
x_vals = [x_min:x_step:x_max];
y_vals = [y_min:y_step:y_max];
num_x_vals = nx + 1;
num_y_vals = ny + 1;
for xi = 1:num_x_vals-1
    for yi = 1:num_y_vals-1
        if x_vals(xi)<=x&x<x_vals(xi+1)&y_vals(yi)<=y&y<y_vals(yi+1)
            index = (yi-1)*nx + xi;
            return
        end
    end
end
