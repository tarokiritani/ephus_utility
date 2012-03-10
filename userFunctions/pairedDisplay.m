function pairedDisplay(varargin)
% pairedDisplay - Used to implement online display of multiple recordings data.
%
% USAGE
%  Bind this function to the xsg:Save event.
%
% NOTES
%
% created by Taro Kiritani Feb 2010 tarokiritani2008@u.northwestern.edu
% modified by Taro Kiritani Sep 2010

global progmanagerglobal pairedfig pairedfignum

% determine whether the figure exists or not. if not, create a new one.
if not(exist('pairedfig','var'))
    pairedfig = figure;
end

try
    figure(pairedfig);
catch
    pairedfig = figure;
    pairedfignum = [];
end
%tracenum =
%length(struct2cell(progmanagerglobal.programs.ephys.ephys.variables.saveBuffers));
acqOnArray = progmanagerglobal.programs.ephys.ephys.variables.acqOnArray;
tracenum = sum(acqOnArray);
acqChannel = find(acqOnArray);

% count the number of traces.
if isempty(pairedfignum)
     pairedfignum = 1;
else
     pairedfignum = pairedfignum + 1;
end

acnumber = str2double(progmanagerglobal.programs.xsg.xsg.variables.acquisitionNumber) - 1;
if acnumber < 10
    acnumber = ['000',num2str(acnumber)];
elseif acnumber < 100
    acnumber = ['00',num2str(acnumber)];
elseif acnumber < 1000
    acnumber = ['0',num2str(acnumber)];
else
    acnumber = num2str(acnumber);
end
xsgdata = [progmanagerglobal.programs.xsg.xsg.variables.directory, '\', ...
    progmanagerglobal.programs.xsg.xsg.variables.initials, ...
    progmanagerglobal.programs.xsg.xsg.variables.experimentNumber, '\', ...
    progmanagerglobal.programs.xsg.xsg.variables.initials, ...
    progmanagerglobal.programs.xsg.xsg.variables.experimentNumber, ...
    progmanagerglobal.programs.xsg.xsg.variables.setID, ...
    acnumber,'.xsg'];
    
xsgdata = load(xsgdata, '-mat', 'data');
% plot the data.
% first, if only one cell fires, the number of traces is tracenum
if length(xsgdata.data.ephys.(['trace_',num2str(acqChannel(1))])) == 40000
    for n = 1:tracenum
        tracename = ['trace_',num2str(acqChannel(n))];
        trace = xsgdata.data.ephys.(tracename);
        for p = 1:4
            subplot(tracenum,4,4 * (n - 1) + p)
             if pairedfignum == 1
                plot(trace(1 + 10000 * (p - 1):10000 + 10000 * (p - 1)),'b');
             else
                avetrace = get(get(gca,'Children'),'YData')*(pairedfignum-1)/pairedfignum + trace(1 + 10000 * (p - 1):10000 + 10000 * (p - 1))'/pairedfignum;
                plot(avetrace,'b')
             end
        end
    end
    
else
    for n = 1:tracenum
     subplot(tracenum,1,n)
     tracename = ['trace_',num2str(acqChannel(n))];
     trace = xsgdata.data.ephys.(tracename);
     
     if pairedfignum == 1
        plot(trace,'b');
     else
        avetrace = get(get(gca,'Children'),'YData')*(pairedfignum-1)/pairedfignum + trace'/pairedfignum;
        plot(avetrace,'b')
     end
    end

end
title(['n = ',num2str(pairedfignum)])
