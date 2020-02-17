function way_pts = CS6380_traj2waypts(traj)
%

num_traj = length(traj(:,1));
way_pts = [traj(1,1:3);traj(:,4:6)];
