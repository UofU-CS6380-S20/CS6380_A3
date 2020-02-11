function action = CS6380_USS_tom_2(percept)
% CS6380_USS_tom_2 - USS agent
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
%     action = CS6380_USS_tom_2(percept);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

MAX_SPEED = 10;
BROADCAST = '*';
MY_ID = 'USS_tom_2';
ANNOUNCE_SELF = 'ANNOUNCE_SELF';
USS_TYPE = 'USS';
UAS_TYPE = 'UAS';

persistent state USS UAS

messages_out = [];

if isempty(state)
    state = 1;
    USS = [];
    UAS = [];
    messages_out = CS6380_make_message(BROADCAST,MY_ID,ANNOUNCE_SELF,[]);
end

del_t = percept.del_t;

messages_in = percept.messages;
action.dx = percept.dx;
action.dy = percept.dy;
action.dz = percept.dz;
action.speed = percept.speed;
action.messages = messages_out;

switch state
    case 1 % first time in
        display('USS_tom_2 Hello');
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
                        [UAS,index] = CS6380_index_UAS(UAS,mess_from);
                    end
                end
            end
        end
end
