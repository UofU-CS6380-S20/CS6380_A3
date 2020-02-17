function [rows,cols] = CS6380_line_between(endpt1,del1,endpt2,del2)
% MNDAS_line_between - return pixels on line between two points
% On input:
%     endpt1 (1x2 vector): row,col of one end point
%     del1 (1x2 vector): offset into pixel 1
%     endpt2 (1x2 vector): row,col of other end point
%     del2 (1x2 vector): offset into pixel 2
% On output:
%     rows (nx1 vector): rows of pixels on line (starts at endpt1)
%     cols (nx1 vector): cols of pixels on line (ends at endpt2)
% Call:
%     [rows,cols] = MNDAS_line_between([21,3],[0.2,0.7],[44,8],[0.3,0.1]);
% Author:
%     T. Henderson
%     UU
%     Spring 2012
%

STEP = 0.01;

im = zeros(max(endpt1(1),endpt2(1)),max(endpt1(2),endpt2(2)));

r1 = endpt1(1);
c1 = endpt1(2);
r2 = endpt2(1);
c2 = endpt2(2);
r1x = r1 + del1(1);
c1x = c1 + del1(2);
r2x = r2 + del2(1);
c2x = c2 + del2(2);
rows(1) = r1;
cols(1) = c1;
done = 0;
r = r1x;
c = c1x;
im(r1,c1) = 1;
theta = posori(atan2(r2x-r1x,c2x-c1x));
d_row = STEP*sin(theta);
d_col = STEP*cos(theta);
dist_1_2 = norm([r1x;c1x]-[r2x;c2x]);
while done==0
    r = r + d_row;
    c = c + d_col;
    d = norm([r1x;c1x]-[r;c]);
    if d>dist_1_2
        done = 1;
    else
        ri = max(1,floor(r));
        ci = max(1,floor(c));
        if im(ri,ci)==0
            im(ri,ci) = 1;
            rows = [rows,ri];
            cols = [cols,ci];
        end
    end
end
if im(r2,c2)==0
    rows = [rows,r2];
    cols = [cols,c2];
end
