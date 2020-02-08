function action = CS6380_UAS_tom_1(percept)
% CS6380_UAS_tom_1 - UAS agent
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

MAX_SPEED = 10;
BROADCAST = '*';
MY_ID = 'UAS_tom_1';
ANNOUNCE_SELF = 'ANNOUNCE_SELF';
USS_TYPE = 'USS';
UAS_TYPE = 'UAS';

persistent state USS UAS state_vars

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
    state_vars(7) = 1; % speed
end

del_t = percept.del_t;

messages_in = percept.messages;
action.dx = state_vars(4);
action.dy = state_vars(5);
action.dz = state_vars(6);
action.speed = state_vars(7);
action.messages = messages_out;

switch state
    case 1 % first time in
        display('USS Hello');
        state = 2;
    case 2 % 
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
                    end
                end
            end
        end
end
