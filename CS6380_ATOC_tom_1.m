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

MAX_SPEED = 10;
BROADCAST = '*';
MY_ID = 'ATOC_tom_1';
ANNOUNCE_SELF = 'ANNOUNCE_SELF';
USS_TYPE = 'USS';
UAS_TYPE = 'UAS';
ATOC_TYPE = 'ATOC';

persistent state USS UAS flights AgentNames AgentTypes A_table uit fig

messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    AgentNames = {'ATOC_tom_1'};
    AgentTypes = {'ATOC'};
    fig = uifigure('Position',[100 100 752 250]);
    uit = uitable('Parent',fig,'Position',[25 50 700 200]);
    A_table = table(AgentNames,AgentTypes);
    A_table.AgentTypes = categorical(A_table.AgentTypes,...
        {'ATOC','USS','UAS'},'Ordinal',true);
    uit.Data = A_table;
    messages_out(1).To = BROADCAST;
    messages_out(1).From = MY_ID;
    messages_out(1).Type = ANNOUNCE_SELF;
end

del_t = percept.del_t;

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
                    if ~strcmp(mess_from,MY_ID) % not from myself
                        if strcmp(mess_from(1:3),USS_TYPE) % from USS
                            % handle USS
                            [USS,index] = CS6380_index_USS(USS,mess_from);
                        elseif strcmp(mess_from(1:3),UAS_TYPE) % from UAS
                            [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                        end
                        [AgentNames,AgentTypes] = ...
                            CS6380_insert_Agent_info(AgentNames,...
                            AgentTypes,mess_from);
                    end
                end
            end
            state = 2;
        case 2 % Show USS, UAS and flights
            A_table = table(AgentNames,AgentTypes);
                A_table.AgentTypes = categorical(A_table.AgentTypes,...
                    {'ATOC','USS','UAS'},'Ordinal',true);
            uit.Data = A_table;
            state = 3;
        case 3 % exit state
            state = 1;
            return
    end
end
