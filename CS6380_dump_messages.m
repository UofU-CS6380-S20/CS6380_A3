function CS6380_dump_messages(fd,count,messages)
%

fprintf(fd,' --- %d --- \n',count);

num_messages = length(messages);
for m = 1:num_messages
    fprintf(fd,' To: %s \n',messages(m).To);
    fprintf(fd,' From: %s \n',messages(m).From);
    fprintf(fd,' Type: %s \n',messages(m).Type);
    fprintf(fd,' Subtype: %s \n\n',messages(m).Subtype);
end
