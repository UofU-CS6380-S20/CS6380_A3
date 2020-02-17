function action = CS6380_UAS_tom_1(percept)
% CS6380_UAS_tom_1 - UAS agent: flies trajectory
% On input:
%     percept (struct vector): agent percept data
%       .x (float): x position of agent
%       .y (float): y position of agent
%       .z (float): z position of agent
%       .dx (float): x heading
%       .dy (float): y heading
%       .dz (float): z heading
%       .speed (float): ground speed
%       .time (float): current time
%       .del_t (float): time step
% On output:
%     action (struct vector): agent actions
%       .dx (float): heading in x
%       .dy (float): heading in y
%       .dz (float): heading in z
%       .speed (float): speed to move
%       .messages (struct vector)
% Call:
%     action = CS6380_UAS_tom_1(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

CS6380_load_ABMS_data;
MY_ID = 'UAS_tom_1';

persistent state USS UAS state_vars
persistent lanes cur_lane num_lanes
persistent ATOC GRS in_flight
persistent p_flights s_flights cur_f_index
messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    state_vars(1) = 10; % x coord
    state_vars(2) = 10; % y coord
    state_vars(3) = 0; % z coord
    state_vars(4) = 1; % dx 
    state_vars(5) = 0; % dy 
    state_vars(6) = 0; % dz 
    state_vars(7) = 0; % speed
    lanes = [];
    num_lanes = 0;
    cur_lane = 0;
    in_flight = 0;
    cur_f_index = 0;
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[],[]);
end

xa = percept.x;
ya = percept.y;
za = percept.z;
dx = percept.dx;
dy = percept.dy;
dz = percept.dz;
realx = [];
realy = [];
realz = [];

speed = percept.speed;
del_t = percept.del_t;
cur_time = percept.time;

messages_in = percept.messages;

done = 0;
while done==0
    switch state
        case 1 %
            award_accepted = 0;
            if ~isempty(messages_in)
                num_messages_in = length(messages_in);
                for m = 1:num_messages_in
                    mess_from = messages_in(m).From;
                    mess_to = messages_in(m).To;
                    mess_type = messages_in(m).Type;
                    mess_subtype = messages_in(m).Subtype;
                    mess_data = messages_in(m).Data;
                    if ~strcmp(mess_from,MY_ID) % not from myself
                        if strcmp(mess_from(1:4),ATOC_TYPE) % from ATOC
                            ATOC.name = mess_from;
                        elseif strcmp(mess_from(1:3),GRS_TYPE) % from GRS
                            GRS.name = mess_from;
                        elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                            [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                        elseif strcmp(mess_from(1:3),USS_TYPE) % from USS
                            [USS,index] = CS6380_index_USS(USS,mess_from);
                        end
                    end
                end
            end
            state = 3;
        case 2 % handle in-flight
            if in_flight==1
                cur_loc = [xa;ya;za];
                if cur_lane>0&cur_lane<=num_lanes
                    goal = lanes(cur_lane,4:6)';
                else
                    goal = lanes(num_lanes,4:6);
                end
                dist = norm(goal-cur_loc)
                if dist<DIST_THRESH
                    cur_lane = cur_lane + 1;
                    if cur_lane<=num_lanes
                        goal = lanes(cur_lane,4:6)';
                    end
                end
                if cur_lane<=num_lanes
                    dir = goal - cur_loc;
                    dir = dir/norm(dir);
                    dx = dir(1);
                    dy = dir(2);
                    dz = dir(3);
                    dist = norm(goal-cur_loc);
                    speed = min(MAX_SPEED,dist/del_t);
                else
                    dx = 0;
                    dy = 0;
                    dz = 0;
                    speed = 0;
                    in_flight = 0;
                end
                messages_out = CS6380_make_message(BROADCAST,MY_ID,TELEMETRY,[],...
                    [xa,ya,za,dx,dy,dz,speed]);
            end
            state = 4;
        case 3  % handle flight launch
            if in_flight==1
                state = 2;
            else
                in_flight = 1;
                pt1 = 40*rand(1,2);
                pt2 = 40*rand(1,2);
                z = 10 + (20-10)*rand;
                lanes = [[pt1,0] [pt1,z]; [pt1,z] [pt2,z]; [pt2,z] [pt2,0]];
                cur_lane = 1;
                num_lanes = length(lanes(:,1));
                realx = pt1(1);
                realy = pt1(2);
                realz = 0;
                state = 2;
            end
        case 4
            state_vars(4) = dx;
            state_vars(5) = dy;
            state_vars(6) = dz;
            state_vars(7) = speed;
            action.dx = state_vars(4);
            action.dy = state_vars(5);
            action.dz = state_vars(6);
            action.speed = state_vars(7);
            action.realx = realx;
            action.realy = realy;
            action.realz = realz;
            action.messages = messages_out;
            state = 1;
            return
    end
end
