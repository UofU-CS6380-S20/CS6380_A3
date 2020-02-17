function action = CS6380_ATOC_tom_1(percept)
% CS6380_ATOC_tom_1 - ATOC agent (Air Traffic Operations Control)
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
%     action = CS6380_ATOC_tom_1(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

global g_fig

CS6380_load_ABMS_data;

MY_ID = 'ATOC_tom_1';

persistent state USS UAS flights AgentNames AgentTypes A_table uit fig
persistent x_min y_min x_max y_max nx ny ports grid_request

messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    grid_request = 0;
    AgentNames = {'ATOC_tom_1'};
    AgentTypes = {'ATOC'};
    fig = uifigure('Position',[100 100 752 250]);
    uit = uitable('Parent',fig,'Position',[25 50 700 200]);
    A_table = table(AgentNames,AgentTypes);
    A_table.AgentTypes = categorical(A_table.AgentTypes,...
        {'ATOC','USS','UAS','GRS'},'Ordinal',true);
    uit.Data = A_table;
    g_fig = fig;
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[],[]);
    mo = CS6380_make_message(BROADCAST,MY_ID,REQUEST_GRID,[],[]);
    messages_out = [messages_out;mo];
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
                    mess_data = messages_in(m).Data;
                    if ~strcmp(mess_from,MY_ID) % not from myself
                        if strcmp(mess_from(1:3),USS_TYPE) % from USS
                            % handle USS
                            [USS,index] = CS6380_index_USS(USS,mess_from);
                        elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                            [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                            if strcmp(mess_type,TELEMETRY)
                                flights = [flights;mess_data];
                            end
                        elseif strcmp(mess_from(1:3),GRS_TYPE)
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
                                grid_request = 0;
                            end
                        end
                        [AgentNames,AgentTypes] = ...
                            CS6380_insert_agent_info(AgentNames,...
                            AgentTypes,mess_from);
                    end
                end
            end
            state = 2;
        case 2 % Show USS, UAS and flights
            [d1,d2] = size(AgentNames);
            if d1==1
                AgentNames = AgentNames';
            end
            [d1,d2] = size(AgentTypes);
            if d1==1
                AgentTypes = AgentTypes';
            end
            A_table = table(AgentNames,AgentTypes);
            A_table.AgentTypes = categorical(A_table.AgentTypes,...
                {'ATOC','USS','UAS','GRS'},'Ordinal',true);
            uit.Data = A_table;
            state = 3;
        case 3  % Flight Display
            if ~isempty(x_min)
                CS6380_display_flights(flights,x_min,y_min,x_max,y_max,...
                    nx,ny);
            end
            state = 4;
        case 4 % exit state
            state = 1;
            return
    end
end
