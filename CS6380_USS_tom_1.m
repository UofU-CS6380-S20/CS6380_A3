function action = CS6380_USS_tom_1(percept)
% CS6380_USS_tom_1 - USS agent
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
%     action = CS6380_USS_tom_1(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

CS6380_load_ABMS_data;
MY_ID = 'USS_tom_1';
LAUNCH_PROB = 1;
MIN_START_GAP = 1;
MAX_START_GAP = 3;

persistent state USS UAS
persistent GRS x_min y_min x_max y_max nx ny grid_request have_grid

messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    grid_request = 0;
    have_grid = 0;
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[]);
end

del_t = percept.del_t;
cur_time = percept.time;

messages_in = percept.messages;
action.dx = percept.dx;
action.dy = percept.dy;
action.dz = percept.dz;
action.speed = percept.speed;
action.messages = messages_out;

done = 0;
while done==0
    switch state
        case 1 % first time in
            display('USS_tom_1: Hello');
            state = 2;
        case 2 %
            if ~isempty(messages_in)
                num_messages_in = length(messages_in);
                for m = 1:num_messages_in
                    mess_from = messages_in(m).From;
                    mess_to = messages_in(m).To;
                    mess_type = messages_in(m).Type;
                    mess_data = messages_in(m).Data;
                    if ~strcmp(mess_from,MY_ID) % not from myself
                        if strcmp(mess_from(1:3),USS_TYPE) % from USS
                            % handle USS
                            [USS,index] = CS6380_index_USS(USS,mess_from);
                        elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                            % handle UAS
                            [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                        elseif strcmp(mess_from(1:3),GRS_TYPE)
                            if isempty(x_min)&grid_request==0
                                mo = CS6380_make_message(mess_from,...
                                    MY_ID,REQUEST_GRID,[]);
                                messages_out = [messages_out;mo];
                                grid_request = 1;
                            elseif isempty(x_min)&grid_request==1 ...
                                    &strcmp(mess_type,GRID)
                                x_min = mess_data(1);
                                y_min = mess_data(2);
                                x_max = mess_data(3);
                                y_max = mess_data(4);
                                nx = mess_data(5);
                                ny = mess_data(6);
                                grid_request = 0;
                                have_grid = 1;
                                GRS.name = mess_from;
                            end
                        end
                    end
                end
            end
            state = 3;
        case 3 % consider new flight
            if rand<LAUNCH_PROB&have_grid==1
                x1 = x_min + (x_max-x_min)*rand;
                y1 = y_min + (y_max-y_min)*rand;
                x2 = x_min + (x_max-x_min)*rand;
                y2 = y_min + (y_max-y_min)*rand;
                start_time = cur_time + MIN_START_GAP...
                    + rand*(MAX_START_GAP-MIN_START_GAP);
                speed = randi(5);
                index1 = CS6380_grid_index(x_min,y_min,x_max,y_max,nx,ny,x1,y1);
                index2 = CS6380_grid_index(x_min,y_min,x_max,y_max,nx,ny,x2,y2);
                ge_list = CS6380_ge_list(index1,index2,nx);
                % Tell GRS ge_list
                mo = CS6380_make_message(GRS.name,MY_ID,IN_GE,ge_list);
                messages_out = [messages_out;mo];            
            end
            state = 4;
        case 4 % exit state
            action.messages = messages_out;
            state = 2;
            done = 1;
    end
end
