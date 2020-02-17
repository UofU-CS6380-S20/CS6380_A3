function p_index = CS6380_p_index(mess_from,mess_subtype,p_flights)
%

p_index = 0;
if isempty(p_flights)
    return
end

num_p_flights = length(p_flights);
for p = 1:num_p_flights
    if strcmp(mess_from,p_flights(p).USS)...
            &strcmp(mess_subtype,p_flights(p).subtype)
        p_index = p;
        return
    end
end
