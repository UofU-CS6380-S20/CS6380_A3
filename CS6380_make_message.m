function message = CS6380_make_message(To,From,Type,Subtype,Data)
% CS6380_make_messase - create message struct from info
% On input:
%     To (string): message intended recipient
%     From (string): message sender
%     Type (string): type of message
%       'ANNOUNCE_SELF'   any agent to world
%       'TELEMETRY'       UAS to USS
%       'REQUEST_GRID'    any agent to GRS
%       'GRID'            GRS to any giving grid
%       'IN_GE'           USS to GRS (inform)
%       'NOT_GE'          USS to GRS (inform)
%       'USS_GE'          USS to GRS (request USS in ge's)
%       'USS_GE'          GRS to USS (inform USS in ge's)
% Call:
%     mo = CS6380_make_message(BROADCAST,MY_ID,'ANNOUNCE_SELF',[]);
% Author:
%     T. Henderson
%     UU
%     Spring 2020
%

message.To = To;
message.From = From;
message.Type = Type;
message.Subtype = Subtype;
message.Data = Data;
