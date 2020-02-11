function res = CS6380_A3_ABMS(fnames,ports,max_t,del_t,draw,film)
% CS6380_A3_ABMS - A3 ABMS simulator
% On input:
%     fnames (struct vector): names of agent function (filenames)
%     ports (nx2 array): launch/land ports (x1 y1)
%     max_t (float): max time to simulate
%     del_t (float): time step increment
%     draw (Boolean): display each simulation step
%     film (Boolean): make a movie from data
% On output:
%     res (struct vector): agent info at each step
%       .agents(k).name
%       .state (kx5 array): state for UAS
%          col 1: agent index
%          col 2: x coord
%          col 3: y coord
%          col 4: z coord
%          col 5: time
% Call:
%     r1 = CS6380_A3_ABMS(fnames,roads,max_t,del_t,0,0);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

MAX_SPEED = 10;
X_MIN = min(ports(:,1));
X_MAX = max(ports(:,1));
Y_MIN = min(ports(:,2));
Y_MAX = max(ports(:,2));

cur_time = 0;
[num_ports,dummy] = size(ports);
num_agents = length(fnames);
agents = zeros(num_agents,9);
% layout:
%   col 1: type (USS: 1; UAS: 2)
%   col 2: x
%   col 3: y
%   col 4: z
%   col 5: dx
%   col 6: dx
%   col 7: dx
%   col 8: speed
%   col 9: t (time of last call)
for a = 1:num_agents
    a_name = fnames(a).name;
    if strcmp(a_name(8:10),'USS')
        agents(a,1) = 1;
    elseif strcmp(a_name(8:10),'UAS')
        agents(a,1) = 2;
    elseif strcmp(a_name(8:11),'ATOC')
        agents(a,1) = 3;
    end
    agents(a,9) = cur_time;
end

messages_in = [];
count = 0;
wb = waitbar(0,'Run ABMS A3');
while cur_time<max_t
    cur_time = cur_time + del_t;
    count = count + 1;
    waitbar(cur_time/max_t);
    messages_out = messages_in;
    messages_in = [];
    for a = 1:num_agents
        % Set up percept
        xa = agents(a,2);
        ya = agents(a,3);
        za = agents(a,4);
        dx = agents(a,5);
        dy = agents(a,6);
        dz = agents(a,7);
        sa = agents(a,8);
        ta = agents(a,9);
        percept.x = xa;
        percept.y = ya;
        percept.z = za;
        percept.dx = dx;
        percept.dy = dy;
        percept.dz = dz;
        percept.speed = sa;
        percept.time = cur_time;
        percept.del_t = del_t;
        percept.messages = messages_out;
        % Call agent
        action = feval(fnames(a).name,percept);
        % Update world
        actions(a) = action;
        percepts(a) = percept;
        messages_in = [messages_in;action.messages];
    end
    % update agent state (execute actions)
    for a = 1:num_agents
        if agents(a,1)==2
            % update heading
            dx = actions(a).dx;
            dy = actions(a).dy;
            dz = actions(a).dz;
            agents(a,5) = dx;
            agents(a,6) = dy;
            agents(a,7) = dz;
            % update speed
            speed = max(min(MAX_SPEED,actions(a).speed),0);
            agents(a,8) = speed;
            % update position
            xa = agents(a,2);
            ya = agents(a,3);
            za = agents(a,4);
            pt = agents(a,2:4)' + speed*[dx;dy;dz]*del_t;
            pt(3) = max(0,pt(3));
            agents(a,2) = pt(1);
            agents(a,3) = pt(2);
            agents(a,4) = pt(3);
        else
            tch = 0;
        end
    end
    res(count).agents = agents;
    % step by step display of agents
    if draw==1
        figure(1);
        clf
        CS6380_draw_A3_state(roads,agents);
    end
    % end of display
end
close(wb);
