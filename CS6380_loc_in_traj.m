function pt = CS6380_loc_in_traj(traj,ts,speed,tc)
%

num_pts = length(traj)/3;
way_pts = reshape(traj,3,num_pts)';
pt = way_pts(1,:);
dist = speed*(tc-ts);
total_dist = 0;
for p = 1:num_pts-1
    cur_dist = norm(way_pts(p+1,:)-way_pts(p,:));
    if dist<=total_dist+cur_dist
        dir = way_pts(p+1,:) - way_pts(p,:);
        dir = dir/norm(dir);
        along = dist - total_dist;
        pt = way_pts(p,:) + along*dir;
        return
    end
    total_dist = total_dist + cur_dist;
end
