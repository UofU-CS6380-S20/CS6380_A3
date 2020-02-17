function CS6380_draw_traj(traj,flights)
%

num_segs = length(traj(:,1));
hold on
for s = 1:num_segs
    plot3([traj(s,1),traj(s,4)],[traj(s,2),traj(s,5)],...
        [traj(s,3),traj(s,6)],'r');
end

num_flights = length(flights);
for f = 1:num_flights
    trajf = flights(f).traj;
    num_segs = length(traj(:,1));
    for s = 1:num_segs
        plot3([trajf(s,1),trajf(s,4)],[trajf(s,2),trajf(s,5)],...
            [trajf(s,3),trajf(s,6)],'b');
    end
end
    