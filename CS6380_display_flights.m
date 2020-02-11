function CS6380_display_flights(flights)
%

figure(2);
clf
plot(-1,-1,'w.');
hold on
axis equal
view(3,3.6);
plot(41,41,'w.');
if isempty(flights)
    num_flights = 0;
else
    num_flights = length(flights(:,1));
end

plot3([0,40],[0,0],[0,0],'k');
plot3([40,40],[0,40],[0,0],'k');
plot3([40,0],[40,40],[0,0],'k');
plot3([0,0],[40,0],[0,0],'k');
for f = 1:num_flights
    x = flights(f,1);
    y = flights(f,2);
    z = flights(f,3);
    if z>=10&z<15
        plot3(x,y,z,'go');
    elseif z>=15&z<=20
        plot3(x,y,z,'b+');
    else
        plot3(x,y,z,'r*');
    end
end
