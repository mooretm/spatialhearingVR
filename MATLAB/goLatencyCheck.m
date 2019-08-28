function VRconnection = goLatencyCheck(VRconnection,freq,dur,modality,reps)
% function goLatencyCheck(vrc,freq,dur,modality)
%
%  A FREQ Hz pure tone of DUR duration will be generated
%  as the test signal for measuring latency between MATLAB
%  and Unity. Specify whether the MODALITY of the test
%  should be audio only ("A"), visual only ("V") or 
%  audiovisual ("AV"). The signal will be presented for 
%  REPS number of times. 
%
%  To establish an initial VRconnection, leave the argument 
%  VRconnection empty ([]). To retain the connection save
%  the function output to a variable. To run the program
%  again, pass the saved VRconnection output from the initial 
%  call. If no output argument is saved (i.e., the function 
%  is called without saving the output), the connection will 
%  automatically terminate. 
%
%  ARGUMENTS:
%  VRconnection: a TCPIP object
%  freq: frequeny of the test stimulus
%  dur: duration of the test stimulus
%  modality: 
%      A: audio only test
%      V: visual only test
%      AV: audiovisual test
%
% Author: Travis Moore
% Author: Chris Stecker
% Date: 8/23/2017
% Last edited: 8/23/2017

%% initialize default values
fs = 48000; % set default sampling rate
amp = 1;
phi = 0;

%% establish connection and set up arena
% set up the connection
if isempty(VRconnection)
portnumber = 4012;
VRconnection = tcpip('0.0.0.0',portnumber,'NetworkRole','server');
fprintf('Opening VRconnection, please connect to this server IP %s:%d\n',...
    char(java.net.InetAddress.getLocalHost.getHostAddress),portnumber);

fopen(VRconnection);
fprintf('Connected\n');
end

fprintf('Press any key to begin test.\n');
flush(VRconnection);
pause; % waiting for keypress

%% make audio and send Unity trigger
[sig t fs] = goMakeSine(amp,freq,dur,phi,fs); % ungated signal
%sig = doEnvelope(sig,fs,dur); % gate the signal

% initialize screen/object color
msgReset = sprintf('LATENCY_TEST BLACK V\n');
ipmsg(VRconnection,msgReset);
flush(VRconnection);
pause(0.25);

% initialize trial parameters
msgSet = sprintf('LATENCY_TEST WHITE %s\n', modality);

% go!
for ii = 1:reps
    sound(sig,fs); % from mac to earphones
    
    pause(0.025) % alpha testing latency correction
    
    ipmsg(VRconnection,msgSet); % from mac to PC/Unity
    pause(dur);
    ipmsg(VRconnection,msgReset); % reset screen to black
    flush(VRconnection);
    pause(1);
end

%% query user: go again?
while 1
    fprintf('\n--------------------------------------\n');
    fprintf('Done.\n\n');
    fprintf('Would you like to send another %s test?\n',modality);
    encore = input('1 = YES\n2 = NO\n');
    if encore == 1
        % go again
        for ij = 1:reps
            sound(sig,fs); % MATLAB
            ipmsg(VRconnection,msgSet); % Unity
            pause(dur); % screen flash duration (same as freq dur)
            ipmsg(VRconnection,msgReset); % reset screen to black
            flush(VRconnection);
            pause(1);
        end
    else
        break
    end
end

fprintf('\nFinished successfully.')
if nargout == 0
    fprintf('\nClosing connection...\n');
    fclose(VRconnection);
    delete(VRconnection);
    delete(vrc);
    fprintf('Goodbye!\n\n');
    return
end
fprintf('\nConnection maintained.\n');
fprintf('Goodbye!\n\n');


%% flush
function flush(VRconnection)
% function flush(VRconnection)
while(get(VRconnection,'BytesAvailable'))
    fgetl(VRconnection);
end

%% getresponse
function [respazim, resptime] = getresponse(VRconnection)
% function [respazim, resptime] = getresponse(VRconnection)
result = '';

ipmsg(VRconnection,'TRIGHEAD\n');

while isempty(result)
    result = fgetl(VRconnection);
    
    if isempty(result) || isempty(strfind(result,'HEAD'))
        result = '';
    end
end

% HEAD messages include transform (position) (rotation)
results = textscan(result,'%f%s(%f,%f,%f)\t(%f,%f,%f)');
resptime = results{1};
respazim = results{7}; % rotation around Unity y axis

%% waitready
function waitready(VRconnection)
% function waitready(VRconnection)
[respazim, resptime] = getresponse(VRconnection);
%fprintf('Start at time %.3f. Head Azim = %.1f\n',resptime,respazim);

%% ipmsg
function ipmsg(t,msg) % send command to Unity
fprintf(t,msg);
pause(0.05);

%% create audio signal ramp
function [enveloped] = doEnvelope(stim,fs,dur)
%% create gating to avoid transients

% make gate based on stimulus length when stimulus is
% shorter than default gate time of 50 ms
if dur <= 0.1
    gatedur = .10 * dur; % gate is 10% of stimulus length
else
    gatedur = .05; % duration of the gate in seconds
end

gate = cos(linspace(pi, 2*pi, fs*gatedur));

% adjust envelope modulator (the gate created above) so that its range
% is within the 0/+1 limits
gate = gate+1; % translate modulator values to the 0/+2 range
gate = gate/2; % compresse the values within the 0/+1 range

% create offset gate by flipping the array
offsetgate = fliplr(gate);

% create 'sustain' portion of envelope
sustain = ones(1, (length(stim)-2*length(gate)));
envelope = [gate, sustain, offsetgate];

enveloped = envelope .* stim;

%% create audio signal
function [sig t fs] = goMakeSine(amp,freq,dur,phi,fs)
% function [pt t fs] = makesine(amp,freq,dur,phi,fs)

t = linspace(0,dur,fs*dur); % time vector
sig = amp*sin(2*pi*freq*t+phi); % sine wave
