function runExfo(portNum, sec)
% RUNEXFO(PORTNUM, SEC) opens exfo coonected at a serial port (e.g. COM1)
% for SEC seconds (0.1 - 999 sec)
try
    s = serial(['COM',num2str(portNum)]);
    fopen(s);
catch
    error('could not connect to an exfo')
end

try
    fprintf(s, 'tt\r');
    secString = [repmat('0', 1, 3 - floor(log10(sec))), num2str(floor(sec*10))];
    fprintf(s, ['c',secString,'\r']);
    fprintf(s, 'oo\r')
end

fclose(s)