function res = CS6380_FNSD_delay(flights)
%

num_flights = length(flights);
res = zeros(num_flights,2);
for f = 1:num_flights
    start_time_or = flights(f).start_time_or;
    start_time = flights(f).start_time;
    sdif = start_time - start_time_or;
    if sdif>0
        res(f,1) = 1;
        res(f,2) = sdif;
    end
end
