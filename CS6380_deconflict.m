function [deconflicted,start_time] = CS6380_deconflict(s_flights,...
    n_flight,del_t,h_t)
%

DELAY = 0.5;

deconflicted = 1;
start_time = n_flight.start_time;
if isempty(s_flights)
    return
end

num_flights = length(s_flights);
speed = n_flight.speed;
traj = n_flight.traj;
h_d = speed*h_t;
way_points = CS6380_traj2waypts(n_flight.traj);
num_pts = length(way_points(:,1));
total_dist = 0;
for s = 1:num_pts-1
    total_dist = total_dist + norm(way_points(s+1,:)-way_points(s,:));
end
time_required = total_dist/speed;
stop_time = start_time + time_required;
f_start_time = zeros(num_flights,1);
f_stop_time = zeros(num_flights,1);
for f = 1:num_flights
    f_start_time(f) = s_flights(f).start_time;
    f_dist = CS6380_traj_dist(s_flights(f).traj);
    f_speed = s_flights(f).speed;
    f_stop_time(f) = s_flights(f).start_time + f_dist/f_speed;
end
done = 0;
while done==0
    done = 1;
    for tc = start_time:del_t:stop_time
        pts = Inf*ones(num_flights,3);
        for f = 1:num_flights
            if tc>f_start_time(f)&tc<f_stop_time(f)
                pts(f,:) = CS6380_loc_in_traj(s_flights(f).traj,...
                    s_flights(f).start_time,s_flights(f).speed,tc);
            end
        end
        if ~isempty(pts)
            n_pt = CS6380_loc_in_traj(traj,start_time,speed,tc);
            dists = sqrt((pts(:,1)-n_pt(1)).^2+(pts(:,2)-n_pt(2)).^2 ...
                + (pts(:,3)-n_pt(3)).^2);
            if min(dists)<h_d
                start_time = start_time + DELAY;
                stop_time = start_time + time_required;
                done = 0;
                break
            end
        end
    end
end
tch = 0;
