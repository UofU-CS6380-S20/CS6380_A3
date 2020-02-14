function res = CS6380_drive_A3_ABMS(max_t,draw,film,dump)
% CS6380_drive_A3_ABMS - overall driver for A3 ABMS
% On input:
%     max_t (float): max simulation time
%     draw (Boolean): draw during simulation
%     film (Boolean): make a movie (not implemented)
% On output:
%     res (struct vector): results 
% Call:
%     r1 = CS6380_drive_A3_ABMS(100,0,0);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

global g_fig

res = [];

ports = [];
x_vals = [0,10,20,30,40];
y_vals = x_vals;
num_x_vals = length(x_vals);
num_y_vals = length(y_vals);
for indx = 1:num_x_vals
    x = x_vals(indx);
    for indy = 1:num_y_vals
        y = y_vals(indy);
        ports = [ports; x,y];
    end
end

del_t = 0.1;
fnames(1).name = 'CS6380_USS_tom_1';
fnames(2).name = 'CS6380_USS_tom_2';
fnames(3).name = 'CS6380_UAS_tom_1';
fnames(4).name = 'CS6380_ATOC_tom_1';
fnames(5).name = 'CS6380_UAS_tom_2';
fnames(6).name = 'CS6380_UAS_tom_3';
fnames(7).name = 'CS6380_UAS_tom_4';
fnames(8).name = 'CS6380_GRS_tom_1';

% clear persistent variables
num_agents = length(fnames);
for a = 1:num_agents
    clear(fnames(a).name);
end
clear('CS6380_A3_ABMS');

res = CS6380_A3_ABMS(fnames,ports,max_t,del_t,draw,film,dump);

if film==1
    M = CS6380_show_trace(ports,state);
end

close(g_fig);
tch = 0;
