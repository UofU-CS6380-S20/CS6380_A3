function [a,b,c] = CS6380_line_fit2D(x1,x2)
% CS6380_line_fit2D - find normal line parameters for line defined by 2 pts
% On input:
%     x1 (2x1 vector): point 1
%     x2 (2x1 vector): point 2
% On output:
%     a (float): first parameter in normal line equation (ax+by+c=0)
%     b (float): second parameter in normal line equation (ax+by+c=0)
%     c (float): third parameter in normal line equation (ax+by+c=0)
% Call:
%     [a,b,c] = CS6380_linefit2D([0;0;0],[1;0;0]);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

d = x2 - x1;
v = [-d(2);d(1)];
v = v/norm(v);
a = v(1);
b = v(2);
c = -a*x1(1) - b*x1(2);
