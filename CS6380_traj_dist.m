function dist = CS6380_traj_dist(traj)
%

dist = 0;
num_segs = length(traj(:,1));
for s = 1:num_segs
    dist = dist + norm(traj(s,4:6)-traj(s,1:3));
end
