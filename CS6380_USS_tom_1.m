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
EXIT = 3;

persistent state USS my_USS_index UAS flights GRS
persistent x_min y_min x_max y_max nx ny grid_request have_grid UTM_grid

messages_out = [];

if isempty(state)
    state = 1;
    [USS,my_USS_index] = CS6380_index_USS([],MY_ID);
    UAS = [];
    flights = [];
    grid_request = 0;
    have_grid = 0;
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[],[]);
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
        case 1  % consider new flight
            if rand<LAUNCH_PROB&have_grid==1
                x1 = x_min + (x_max-x_min)*rand;
                y1 = y_min + (y_max-y_min)*rand;
                x2 = x_min + (x_max-x_min)*rand;
                y2 = y_min + (y_max-y_min)*rand;
                z = Z_MIN + rand*(Z_MAX - Z_MIN);
                traj = [x1 y1 0 x1 y1 z; x1 y1 z x2 y2 z; x2 y2 z x2 y2 0];
                start_time = cur_time + MIN_START_GAP...
                    + rand*(MAX_START_GAP-MIN_START_GAP);
                speed = randi(5);
                dist = CS6380_traj_dist(traj);
                required_time = dist/speed;
                ge_list = CS6380_ge_list(x1,y1,x2,y2,UTM_grid);
                num_flights = length(flights);
                new_flight.id = num_flights + 1;
                new_flight.traj = traj;
                new_flight.speed = speed;
                new_flight.start_time_or = start_time;
                new_flight.start_time = start_time;
                new_flight.stop_time = start_time + required_time;
                new_flight.UAS = [];
                new_flight.telemetry = [];
                new_flight.ge_list = ge_list;
                new_flight.ge_USS_list = [];
                new_flight.USS = [];
                new_flight.USS_response = [];
                new_flight.s_flights = [];
                new_flight.bidders = [];
                new_flight.status = 1;
                [dec,start_time_dec] = CS6380_deconflict(flights,new_flight,...
                    del_t, H_T);
                new_flight.start_time = start_time_dec;
                new_flight.stop_time = start_time + required_time;
                flights = [flights;new_flight];
                % Tell GRS ge_list
                mo = CS6380_make_message(GRS.name,MY_ID,IN_GE,[],ge_list);
                messages_out = [messages_out;mo];
                num_flights = length(flights);
                mo = CS6380_make_message(GRS.name,MY_ID,USS_GE,...
                    num2str(num_flights),ge_list);
                messages_out = [messages_out;mo];
            end
            state = 2;
        case 2 % handle messages
            state = 4;
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
                            tch = 0; % unused for now
                        elseif strcmp(mess_from(1:3),GRS_TYPE) % from GRS
                            if isempty(x_min)&grid_request==0
                                mo = CS6380_make_message(mess_from,...
                                    MY_ID,REQUEST_GRID,[],[]);
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
                                UTM_grid = mess_data;
                                grid_request = 0;
                                have_grid = 1;
                                GRS.name = mess_from;
                            elseif strcmp(mess_type,USS_GE) % ge_USS_list
                                f = str2num(mess_subtype);
                                flights(f).status = 2;
                                [USS,pairs] = CS6380_extract_pairs(USS,...
                                    mess_data);
                                indexes = find(pairs(:,2)==my_USS_index);
                                pairs(indexes,:) = [];
                                flights(f).USS_response = pairs;
                                if isempty(pairs)
                                    state = 3;
                                    flights(f).status = 3;
                                else
                                    num_pairs = length(pairs(:,1));
                                    USS_list = [];
                                    for p = 1:num_pairs
                                        USS_list = union(USS_list,pairs(p,2));
                                    end
                                    num_USS_list = length(USS_list);
                                    for u = 1:num_USS_list
                                        u_name = USS(USS_list(u)).name;
                                        if ~strcmp(u_name,MY_ID)
                                            ge_list = find(pairs(:,2)==...
                                                USS_list(u));
                                            mo = CS6380_make_message(u_name,...
                                                MY_ID,REQUEST_FLIGHTS,...
                                                num2str(f),ge_list);
                                            messages_out = [messages_out;mo];
                                        end
                                    end
                                end
                            end
                        elseif strcmp(mess_from(1:3),USS_TYPE) % from USS
                            [USS,index] = CS6380_index_USS(USS,mess_from);
                        elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                            % handle UAS
                            [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                        end
                    end
                end
            end
        case 3 % CFB
            flights(f).USS_response = pairs;
            state = 4;
        case 4 % exit state
            action.messages = messages_out;
            state = 1;
            done = 1;
    end
end
