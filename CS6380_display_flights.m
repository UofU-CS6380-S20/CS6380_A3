function CS6380_display_flights(flights,x_min,y_min,x_max,y_max,nx,ny)
%

figure(2);
clf
plot(-1,-1,'w.');
hold on
axis equal
view(65,8);
plot(x_max+1,y_max+1,'w.');
if isempty(flights)
    num_flights = 0;
else
    num_flights = length(flights(:,1));
end

plot3([x_min,x_max],[y_min,y_min],[0,0],'k');
plot3([x_max,x_max],[y_min,y_max],[0,0],'k');
plot3([x_max,x_min],[y_max,y_max],[0,0],'k');
plot3([x_min,x_min],[y_max,y_min],[0,0],'k');
plot3(x_max,y_max,30,'w.');

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
