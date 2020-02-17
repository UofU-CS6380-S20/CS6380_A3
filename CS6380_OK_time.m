function b = CS6380_OK_time(start_time,stop_time,s_flights)
%

b = 1;

if isempty(s_flights)
    return
end

num_flights = length(s_flights);
for f = 1:num_flights
    f1 = s_flights(f).start_time;
    f2 = s_flights(f).stop_time;
    if ~(f2<=start_time|f1>=stop_time)
        b = 0;
        return
    end
end
