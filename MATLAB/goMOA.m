function goMOA(subject, condition)
% function goBalloons(subject, condition)
%
%  Control all aspects of Travis' dissertation experiment: file management,
%  stimulus generation, VR connection, send/receive Unity triggers, MATLAB 
%  audio playback, subject response recording, generation of appropriate
%  plot for current session.
%
%    ARGUMENTS
%    subject: must be a STRING containing a subject NUMBER. I know that's
%      odd... The string is used for naming files, but is also converted to
%      a number to store with each trial in the data structure.
%    condition: must be a string, matching a condition from the key (see
%      data.key below, or the study protocol).
%
%  Author: Travis Moore
%  Author: Chris Stecker (VR implementation)
%  Date: 7/19/2017
%  Last edited: 2/12/2018

%% perform some validation and initialization
% number of arguments
if nargin < 2
    fprintf('Not enough arguments!\n');
    return
end

% Values used in this study:
%ITDs: -270, -180, -90, 0, 90, 180, 270 
%ILDs: -9, -6, -3, 0, 3, 6, 9

fs = 48000; % set default sampling rate
ISI = 0.5; % set default interstimulus interval
%level = -20; % this is set in doRampedTones.m
freq = 500;
dur = 0.2;
rampdur = 0.02;

% does an experiment folder exist?
if exist('Travis_Dissertation','dir') ~= 7
    fprintf('\n--------------------------------------\n');
    fprintf('No DATA FOLDER found!');
    fprintf('\n--------------------------------------\n');
    fprintf('This is normal when running for the first time.\n\n');
    fprintf('Create data folder ''Travis_Dissertation''?\n');
    createDataFolder = input('1 = YES\n2 = NO\n');
    if createDataFolder == 1
        mkdir('Travis_Dissertation');
        addpath('Travis_Dissertation');
    else if createDataFolder == 2
            fprintf('Goodbye!\n');
            return;
        end
    end
end

addpath('Travis_Dissertation');

% does a subject folder exist?
if exist(['Travis_Dissertation/' subject],'dir') ~= 7
    fprintf('\n--------------------------------------\n');
    fprintf('No SUBJECT FOLDER found!');
        fprintf('\n--------------------------------------\n');
    fprintf('This is normal when running for the first time.\n\n');
    fprintf(['Create subject folder for ', subject, '?\n'])
    createSubFolder = input('1 = YES\n2 = NO\n');
    if createSubFolder == 1
        mkdir(['Travis_Dissertation/',subject]);
        addpath(['Travis_Dissertation/',subject]);
    else if createSubFolder == 2
            fprintf('Goodbye!\n')
            return
        end
    end
end

myPath = ['Travis_Dissertation/', subject, '/']; 

% does a subject data file exist?
if exist([myPath, subject '.mat'],'file') ~= 2
    fprintf('\n--------------------------------------\n');
    fprintf('Create new subject file?\n\n')
    createFile = input('1 = YES\n2 = NO\n');
    if createFile == 1
         data.id = subject;
        
        %experiment 1 ORGANIZATION
        data.info(1,1,1) = {'data.condition(#).trials(row,col,page/block)'};
        data.info(2,1,1) = {'trial columns:'};
        data.info(3,1,1) = {'1: Subject'};
        data.info(4,1,1) = {'2: Experiment'};
        data.info(5,1,1) = {'3: Condition'};
        data.info(6,1,1) = {'4: Block'};     
        data.info(7,1,1) = {'5: Probe ITD'};
        data.info(8,1,1) = {'6: Probe ILD'};
        data.info(9,1,1) = {'7: Adjustment UP'};
        data.info(10,1,1) = {'8: Adjustment DOWN'};
        data.info(11,1,1) = {'9: System Time'};
        
        %experiment 2 ORGANIZATION
        data.info(1,1,2) = {'data.condition(#).trials(row,col,page/block)'};
        data.info(2,1,2) = {'trial columns:'};
        data.info(3,1,2) = {'1: Subject'};
        data.info(4,1,2) = {'2: Experiment'};
        data.info(5,1,2) = {'3: Condition'};
        data.info(6,1,2) = {'4: Adaptor type'};     
        data.info(7,1,2) = {'5: ITD'};
        data.info(8,1,2) = {'6: ILD'};
        data.info(9,1,2) = {'7: Send time'};
        data.info(10,1,2) = {'8: Response azimuth'};
        data.info(11,1,2) = {'9: Response time'};

        %experiment 3 ORGANIZATION
        data.info(1,1,3) = {'data.condition(#).trials(row,col,page/block)'};
        data.info(2,1,3) = {'trial columns:'};
        data.info(3,1,3) = {'1: Subject'};
        data.info(4,1,3) = {'2: Experiment'};
        data.info(5,1,3) = {'3: Condition'};
        data.info(6,1,3) = {'4: Adaptor type'};     
        data.info(7,1,3) = {'5: ITD'};
        data.info(8,1,3) = {'6: ILD'};
        data.info(9,1,3) = {'7: Send time'};
        data.info(10,1,3) = {'8: Response azimuth'};
        data.info(11,1,3) = {'9: Response time'};

        %experiment 1 CONDITIONS
        data.key(1,1) = {'1. ITD_m270'};
        data.key(2,1) = {'2. ITD_m180'};
        data.key(3,1) = {'3. ITD_m90'};
        data.key(4,1) = {'4. ITD_0'};
        data.key(5,1) = {'5. ITD_90'};
        data.key(6,1) = {'6. ITD_180'};
        data.key(7,1) = {'7. ITD_270'};
        data.key(8,1) = {'8. ILD_m9'};
        data.key(9,1) = {'9. ILD_m6'};
        data.key(10,1) = {'10. ILD_m3'};
        data.key(11,1) = {'11. ILD_0'};
        data.key(12,1) = {'12. ILD_3'};
        data.key(13,1) = {'13. ILD_6'};
        data.key(14,1) = {'14. ILD_9'};
        
        %experiment 2 CONDITIONS
        data.key(30,1) = {'30. no_adaptor'};
        
        %experiment 3 CONDITIONS
        data.key(50,1) = {'50. ildAdaptor_comboProbe'};
        data.key(51,1) = {'51. itdAdaptor_comboProbe'};
                
        %room for expansion
        data.key(99,1) = {'99. placeholder'};

        %store trial data here
        data.condition(99).trials = [];
        
        save([myPath, subject '.mat'], 'data');
    else
        fprintf('Goodbye!\n');
        return
    end
end 

load([myPath, subject '.mat']);

% standard stimuli are always at midline
standardILD = 0;
standardITD = 0;

% assign condition, experiment and adaptor
switch condition
    % fixed ITD    
    case 'ITD_m270'
        condNum = 1;
        expNum = 1;
        probeITD = -270;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_m180'
        condNum = 2;
        expNum = 1;
        probeITD = -180;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_m90'
        condNum = 3;
        expNum = 1;
        probeITD = -90;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_0'
        condNum = 4;
        expNum = 1;
        probeITD = 0;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_90'
        condNum = 5;
        expNum = 1;
        probeITD = 90;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_180'
        condNum = 6;
        expNum = 1;
        probeITD = 180;
        probeILD = randi([-9, 9],1,1);
    case 'ITD_270'
        condNum = 7;
        expNum = 1;
        probeITD = 270;
        probeILD = randi([-9, 9],1,1);

    % fixed ILD
    case 'ILD_m9'
        condNum = 8;
        expNum = 1;
        probeILD = -9;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_m6'
        condNum = 9;
        expNum = 1;
        probeILD = -6;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_m3'
        condNum = 10;
        expNum = 1;
        probeILD = -3;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_0'
        condNum = 11;
        expNum = 1;
        probeILD = 0;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_3'
        condNum = 12;
        expNum = 1;
        probeILD = 3;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_6'
        condNum = 13;
        expNum = 1;
        probeILD = 6;
        probeITD = randi([-270, 270],1,1);
    case 'ILD_9'
        condNum = 14;
        expNum = 1;
        probeILD = 9;
        probeITD = randi([-270, 270],1,1);
    otherwise
        fprintf('Invalid condition!\nAborting\n\n');
        return
end

% determine block number
dimensions = size(data.condition(condNum).trials); % how many dimensions are there? 2 or 3?
pages = size(data.condition(condNum).trials,3); % looks for 3d dimension value
fSum = sum(data.condition(condNum).trials); % sum of all data in 1st dimension

if length(dimensions) < 3 && fSum(1) == 0
    blockNum = 1;
elseif length(dimensions) < 3 && fSum(1) > 0
    blockNum = 2;
elseif length(dimensions) >= 3
    blockNum = pages + 1;
end

% display the session parameters
fprintf('Subject: %s\n', data.id);
fprintf('Experiment: %d\n', expNum);
fprintf('Condition #: %d\n', condNum);
charCondition = char(data.key(condNum));
fprintf('Condition: %s\n', charCondition);
fprintf('Starting block number: %d\n', blockNum);

%% establish connection and set up arena
% set up the connection
portnumber = 4012;
VRconnection = tcpip('0.0.0.0',portnumber,'NetworkRole','server');
fprintf('Opening VRconnection, please connect to this server IP %s:%d\n',...
    char(java.net.InetAddress.getLocalHost.getHostAddress),portnumber);
%fprintf('Opening VRconnection, please connect to this server IP 127.0.0.1:4012');
% for mac: 192.168.2.27

fopen(VRconnection);
fprintf('Connected\n');

%configure the Unity project (Shooting Gallery):
ipmsg(VRconnection,'TERRAIN ON\n'); % options: ON, OFF and TOG
ipmsg(VRconnection,'FLOOR WATER\n'); % options: CHECK, WATER, BRICK, ON, OFF, TOG
ipmsg(VRconnection,'HOMEBOX OFF\n');

% reset the balloon array
ipmsg(VRconnection,'CLEAR ALL\n');

ipmsg(VRconnection,'REPOPULATE\n'); % this lets Unity quickly set all balloons
% much slower but under matlab control:
%for az = 0:359, ipmsg(VRconnection,sprintf('TARG %d noname true RED\n',az)); end

ipmsg(VRconnection,'COLOR 0 GREEN\n'); % turn the reference balloon green
fprintf('Waiting for user...');
flush(VRconnection);

waitready(VRconnection);

fprintf('ready\n');
% a little display to show the user we are ready to go
ipmsg(VRconnection,'BOB -20\n');
ipmsg(VRconnection,'BOB 0\n');
ipmsg(VRconnection,'BOB 20\n');
flush(VRconnection);

%% prepare stimuli
% store number of button presses from Unity during adjustment
valUp = 0;
valDown = 0;

% assign the appropriate step size to add to the probe
%    based on the condition. Also, specify condition. 
if condNum <= 7
    stepVal = 0.1;
    paradigm = 'ILD';
elseif condNum >= 8
    stepVal = 10; % microseconds
    paradigm = 'ITD';
end

%% begin trials
count = 0;
stopLoop = 0;
while stopLoop == 0
    tic;
    count = count + 1;

    flush(VRconnection);
    ipmsg(VRconnection,'CHECK_LOOP\n');
    stopLoop = str2double(fgetl(VRconnection));

    % record stimulus and id information for each trial
    data.condition(condNum).trials(count,1,blockNum) = str2double(subject);
    data.condition(condNum).trials(count,2,blockNum) = expNum;
    data.condition(condNum).trials(count,3,blockNum) = condNum;
    data.condition(condNum).trials(count,4,blockNum) = blockNum;
    data.condition(condNum).trials(count,5,blockNum) = probeITD;
    data.condition(condNum).trials(count,6,blockNum) = probeILD;
    data.condition(condNum).trials(count,7,blockNum) = valUp;
    data.condition(condNum).trials(count,8,blockNum) = valDown;
    
    ipmsg(VRconnection,'COLOR 0 GREEN\n'); % set 0 deg balloon to green
    
    % enable the homebox and change cursor
    ipmsg(VRconnection,'HOMEBOX ON\n');
    ipmsg(VRconnection,'GAZE ON\n');
    ipmsg(VRconnection,'ARMDISPLAY OFF\n');
    
    % wait for subject to put head in box before continuing trial
    fprintf('waiting...');
    waithome(VRconnection);
    fprintf('ready...');
    fprintf('\n\tTrial #: %d',count);
    
    % disable homebox 
    ipmsg(VRconnection,'HOMEBOX OFF\n');
    
    % play stimulus and record send time
    %standardSig = doBinauralCue2('combo',standardITD,standardILD,level,freq,dur,fs,t);
    standardSig = doRampedTones(freq,dur,rampdur,standardITD,standardILD,fs);
    tt=toc;
    sound(standardSig,fs);
    
    pause(ISI);
    
    flush(VRconnection);
    ipmsg(VRconnection,'CLICK_COUNT\n');
    btnCount = fgetl(VRconnection);
    btnCount = strsplit(btnCount, ' ');
    valUp = str2double(btnCount(1)) * stepVal;
    valDown = str2double(btnCount(2)) * stepVal;
    if strcmp(paradigm,'ILD')
        probeILD = probeILD + (valUp + valDown);
    elseif strcmp(paradigm,'ITD')
        probeITD = probeITD + (valUp + valDown);
    end
    %probe = doBinauralCue2('combo',probeITD,probeILD,level,freq,dur,fs,t);
    [~,~,probe] = doRampedTones(freq,dur,rampdur,probeITD,probeILD,fs);
    sound(probe,fs);
    
    plot(probe(:,1),'b');
    hold on
    plot(probe(:,2),'r');
    hold off
    title(['Adjusting: ', paradigm]);
%     subplot(3,1,1)
%         plot(standardSig);
%         title('Standard Signal (Always Midline)');
%         xlabel('Time (ms)');
%         ylabel('Amplitude');
%     subplot(3,1,2)
%         plot(probe);
%         title(['Adjusting: ', paradigm]);
%         %xlim([0 0.05]);
%         xlim([0 30]);
%         xlabel('Time (ms)');
%         ylabel('Amplitude');
%     subplot(3,1,3)
%         envelope(probe);
%         xlabel('The envelopes should move when adjusting ITD');
%         ylabel('Amplitude');

    pause(ISI-tt); % this accounts for the processing time

    ipmsg(VRconnection,sprintf('COLOR 150 RED\n')); % any action to create Unity time stamp
    getInfo = textscan(fgetl(VRconnection),'%f%s%f','Delimiter','\t');
    sendTime = getInfo{1};
    data.condition(condNum).trials(count,9,blockNum) = sendTime; % store sendTime
    
    % display stimulus information for trial
    fprintf('\n\tITD: %d\tILD: %d\tSent: %.2fs...',probeITD,probeILD,sendTime);
    fprintf('done\n');
    if strcmp(paradigm,'ILD')
        fprintf('\tLeft: %d\tRight: %d',valUp,valDown);
        fprintf('\n\tValue: %d\n\n',probeILD);
    elseif strcmp(paradigm,'ITD')
        fprintf('\tLeft: %d\tRight: %d',valUp,valDown);
        fprintf('\n\tValue: %d\n\n',probeITD);
    end

end

% save 2 forms of the subject data file:
%   1. the entire data set that will be appended to each session
%   2. the data set from just this session with date stamp
theTime = datetime('now');
[y,m,d] = ymd(theTime);
str = sprintf('%d-%d-%d_%s_E%dC%dB%d',m,d,y,subject,expNum,condNum,blockNum);
save([myPath, subject '.mat'], 'data');
save([myPath, str '.mat'], 'data');

pause(0.25);

%% wrap up session
% replace the balloon (if vanished) and change center balloon to red
ipmsg(VRconnection,'RESPAWN\n');
ipmsg(VRconnection,sprintf('COLOR 0 RED\n'));

pause(0.25);

% two different colors (blue and yellow) move from sides to center
for ii = 20:-1:1
    ipmsg(VRconnection,sprintf('COLOR %d YELLOW\n',ii-1));
    ipmsg(VRconnection,sprintf('COLOR %d BLUE\n',-ii));
end

% a third color (green) moves from center to sides 
for ii = 1:20
    ipmsg(VRconnection,sprintf('COLOR %d GREEN\n',ii-1));
    ipmsg(VRconnection,sprintf('COLOR %d GREEN\n',-ii));
end

pause(0.25);

%% plot current session data
figure;
if strcmp(paradigm,'ILD')
    yVals = data.condition(condNum).trials(:,6,blockNum);
    yVals(yVals==0) = [];
    xVals = length(yVals);

    plot(1:1:(xVals),yVals,'bo');
    %ylim([(min(yVals)-1),(max(yVals)+1)]);
    ylim([-10,10]);
    line([1,xVals],[data.condition(condNum).trials(1,6,blockNum), ...
         data.condition(condNum).trials(1,6,blockNum)],'Color','red');
    line([1,xVals],[standardILD,standardILD],'Color','green');
    title(['ILD adjustments for ITD = ', num2str(probeITD)]);
    %title(data.key(condNum),'Interpreter','none');
    xlabel('Trial Number');
    %set(gca,'xtick',ITDs)
    ylabel('ILD (dB)');
    
elseif strcmp(paradigm,'ITD')
    yVals = data.condition(condNum).trials(:,5,blockNum);
    yVals(yVals==0) = [];
    xVals = length(yVals);

    plot(1:1:(xVals),yVals,'bo');
    %ylim([(min(yVals)-1),(max(yVals)+1)]);
    ylim([-270,270]);
    line([1,xVals],[data.condition(condNum).trials(1,5,blockNum), ...
         data.condition(condNum).trials(1,5,blockNum)],'Color','red');
    line([1,xVals],[standardILD,standardILD],'Color','green');
    title(['ITD adjustments for ILD = ', num2str(probeILD)]);
    %title(data.key(condNum),'Interpreter','none');
    xlabel('Trial Number');
    %set(gca,'xtick',ITDs)
    ylabel('ITD (\muS)');
end

%% disconnect        
ipmsg(VRconnection,'CLEAR ALL\n');
fprintf('\nFinished successfully.\nClosing connection... Goodbye!\n\n')

fclose(VRconnection);
delete(VRconnection);

end


%% ----------------------------- FUNCTIONS -----------------------------
%% flush
function flush(VRconnection)
% function flush(VRconnection)
while(get(VRconnection,'BytesAvailable'))
    fgetl(VRconnection);
end
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
end

%% waitready
function waitready(VRconnection)
% function waitready(VRconnection)
[respazim, resptime] = getresponse(VRconnection);
fprintf('Start at time %.3f. Head Azim = %.1f\n',resptime,respazim);
end

%% waithome
function ready = waithome(VRconnection)
% function ready = waithome(VRconnection)
ready = 0;
result = '';
flush(VRconnection);

while ~ready
    try
        flush(VRconnection);
        ipmsg(VRconnection,'HOMECHECK\n');
        result = fgetl(VRconnection);
    catch
        % do nothing
    end
    
    if isempty(result) || isempty(strfind(result,'HOMECHECK')), continue; end
    
    results = textscan(result,'%f%s%f','Delimiter','\t');
    hometime = results{3};
    
    if hometime >= 2 % stay home for 2 seconds
        ready = 1;
    end
end
end

%% ipmsg
function ipmsg(t,msg) % send command to Unity
fprintf(t,msg);
pause(0.05);
end


