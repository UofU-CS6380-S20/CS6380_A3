function action = CS6380_UAS_tom_2(percept)
% CS6380_UAS_tom_2 - UAS agent: flies trajectory
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
%     action = CS6380_UAS_tom_2(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

MAX_SPEED = 10;
BROADCAST = '*';
TELEMETRY = 'TELEMETRY';
MY_ID = 'UAS_tom_2';
ANNOUNCE_SELF = 'ANNOUNCE_SELF';
USS_TYPE = 'USS';
UAS_TYPE = 'UAS';
DIST_THRESH = 0.1;

persistent state USS UAS state_vars
persistent lanes cur_lane num_lanes

messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    messages_out(1).To = BROADCAST;
    messages_out(1).From = MY_ID;
    messages_out(1).Type = ANNOUNCE_SELF;
    state_vars(1) = 0; % x coord
    state_vars(2) = 0; % y coord
    state_vars(3) = 0; % z coord
    state_vars(4) = 1; % dx 
    state_vars(5) = 0; % dy 
    state_vars(6) = 0; % dz 
    state_vars(7) = 0; % speed
    lanes = [0 0 0 0 0 20; 0 0 20 10 0 20; 10 0 20 10 0 0];
    num_lanes = length(lanes(:,1));
    cur_lane = 1;
end

xa = percept.x;
ya = percept.y;
za = percept.z;
dx = percept.dx;
dy = percept.dy;
dz = percept.dz;
speed = percept.speed;
del_t = percept.del_t;

messages_in = percept.messages;

switch state
    case 1 % 
        if ~isempty(messages_in)
            num_messages_in = length(messages_in);
            for m = 1:num_messages_in
                mess_from = messages_in(m).From;
                mess_to = messages_in(m).To;
                mess_type = messages_in(m).Type;
                if ~strcmp(mess_from,MY_ID) % not from myself
                    if strcmp(mess_from(1:3),USS_TYPE) % from USS
                        % handle USS
                        [USS,index] = CS6380_index_USS(USS,mess_from);
                    elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                        % handle UAS
                        [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                    end
                end
            end
        end
        cur_loc = [xa;ya;za];
        if(cur_lane <= num_lanes)
            goal = lanes(cur_lane,4:6)';
        else
            goal = lanes(num_lanes,4:6)';
        end
        dist = norm(goal-cur_loc);
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
        end
        messages_out = CS6380_make_message(BROADCAST,MY_ID,TELEMETRY,...
            [xa,ya,za,dx,dy,dz,speed]);
end

state_vars(4) = dx;
state_vars(5) = dy;
state_vars(6) = dz;
state_vars(7) = speed;
action.dx = state_vars(4);
action.dy = state_vars(5);
action.dz = state_vars(6);
action.speed = state_vars(7);
action.messages = messages_out;

end

