function index = CS6380_next_flight(s_flights,cur_time)
%

START_THRESH = 0.09;

index = 0;

if isempty(s_flights)
    return
end

num_s_flights = length(s_flights);
min_t = Inf;
min_index = 0;
for f = 1:num_s_flights
    start_time = s_flights(f).start_time;
    del = start_time - cur_time;
    if del<min_t
        min_t = del;
        min_index = f;
    end
end
if del<START_THRESH
    index = min_index;
end
