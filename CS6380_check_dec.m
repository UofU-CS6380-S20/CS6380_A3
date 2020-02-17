function res = CS6380_check_dec(flights1,flights2)
%

num1 = length(flights1);
num2 = length(flights2);
res = [];
for f = 1:num1
    f1 = flights1(1);
    for g = 1:num2
        f2 = flights2(g);
        [dec,start_time] = CS6380_deconflict(f2,f1,0.1,1);
        if start_time~=f1.start_time
            res = [res;f];
        end
    end
end
