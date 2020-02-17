function action = CS6380_GRS_tom_1(percept)
% CS6380_GRS_tom_1 - Grid Reservation System
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
%     action = CS6380_GRS_tom_1(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

CS6380_load_ABMS_data;
MY_ID = 'GRS_tom_1';

persistent state x_min x_max y_min y_max nx ny grid
persistent ge_USS num_ge USS

messages_out = [];

if isempty(state)
    state = 1;
    x_min = 0;
    x_max = 40;
    y_min = 0;
    y_max = 40;
    nx = 4;
    ny = 4;
    num_ge = nx*ny;
    grid = [x_min y_min x_max y_max nx ny];
    for g = 1:num_ge
        ge_USS(g).USS = [];
    end
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[],[]);
end

del_t = percept.del_t;
flights = [];

messages_in = percept.messages;
action.dx = percept.dx;
action.dy = percept.dy;
action.dz = percept.dz;
action.speed = percept.speed;
action.messages = messages_out;

done = 0;
while done==0
    switch state
        case 1 % handle messages
            if ~isempty(messages_in)
                num_messages_in = length(messages_in);
                for m = 1:num_messages_in
                    mess_from = messages_in(m).From;
                    mess_to = messages_in(m).To;
                    mess_type = messages_in(m).Type;
                    mess_subtype = messages_in(m).Subtype;
                    mess_data = messages_in(m).Data;
                    if ~strcmp(mess_from,MY_ID) % not from myself
                        if strcmp(mess_type,REQUEST_GRID)
                            mo = CS6380_make_message(...
                                mess_from,MY_ID,GRID,[],grid);
                            messages_out = [messages_out;mo];
                        elseif strcmp(mess_from(1:3),USS_TYPE) % from USS
                            % handle USS
                            [USS,USS_index] = CS6380_index_USS(USS,...
                                mess_from);
                            switch mess_type
                                case IN_GE
                                    if ~isempty(mess_data)
                                        num_ge = length(mess_data);
                                        for g = 1:num_ge
                                            ge_index = mess_data(g);
                                            ge_USS(ge_index).USS = union(...
                                                ge_USS(ge_index).USS,...
                                                USS_index);
                                        end
                                    end
                                case NOT_GE
                                    if ~isempty(mess_data)
                                        num_ge = length(mess_data);
                                        for g = 1:num_ge
                                            ge_index = mess_data(g);
                                            ge_USS(ge_index).USS = ...
                                                set_diff(...
                                                ge_USS(ge_index).USS,...
                                                USS_index);
                                        end
                                    end
                                case USS_GE
                                    if ~isempty(mess_data)
                                        num_ge = length(mess_data);
                                        for g = 1:num_ge
                                            list(g).ge = mess_data(g);
                                            ge_index = mess_data(g);
                                            USS_indexes = ...
                                                ge_USS(ge_index).USS;
                                            num_USS_indexes = length(...
                                                USS_indexes);
                                            list(g).USS = [];
                                            for u = 1:num_USS_indexes
                                                list(g).USS = [list(g).USS;...
                                                    USS(USS_indexes(u)).name];
                                            end
                                        end
                                        mo = CS6380_make_message(...
                                            mess_from,MY_ID,USS_GE,...
                                            mess_subtype,list);
                                        messages_out = [messages_out;mo];                                        
                                    end
                            end
                        end
                    end
                end
            end
            done = 1;
    end
end
action.messages = messages_out;
