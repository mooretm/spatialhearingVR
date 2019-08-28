function goMOCS(subject, condition)
% function goMOCS(subject, condition)
%
%  Control all aspects of Travis' dissertation experiment: file management,
%  stimulus generation, VR connection, send/receive Unity triggers, MATLAB 
%  audio playback, subject response recording, generation of surface model 
%  for current session.
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
%  Last edited: 12 February 2018

%% perform some validation and initialization
% number of arguments
if nargin<2
    fprintf('Not enough arguments!\n');
    return
end

%% set defaults
%ITDs = [-270, -180, -90, 0, 90, 180, 270]; % must be ascending for surface plot
%ILDs = [-9, -6, -3, 0, 3, 6, 9]; % must be ascending for surface plot

% for alpha testing
ITDs = [-180, 90];
ILDs = [-3, 6];

ITI = 1; % set default intertrial interval
FS = 48000; % set default sampling rate
%level = -20; % this is now set in doRampedTones.m

%% data organization
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
        data.key(50,1) = {'50. itdAdaptor'};
        data.key(51,1) = {'51. ildAdaptor'};
                
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

%% assign condition
load([myPath, subject '.mat']);

% assign condition, experiment and adaptor
switch condition
    case 'no_adaptor'
        condNum = 30;
        expNum = 2;
        adaptorType = 'none';
        adaptorTypeNum = 0;
    case 'itdAdaptor'
        condNum = 50;
        expNum = 3;
        adaptorType = 'itd';
        adaptorTypeNum = 1;
    case 'ildAdaptor'
        condNum = 51;
        expNum = 3;
        adaptorType = 'ild';
        adaptorTypeNum = 2;
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
charCondition = char(data.key(condNum));
fprintf('Condition: %s\n', charCondition);
fprintf('Adaptor type: %s\n', adaptorType);
fprintf('Starting block number: %d\n', blockNum);

% initialize random trial presentations
valsITD = sort(repmat(ITDs,1,length(ITDs))); % must be sorted
valsILD = repmat(ILDs,1,length(ITDs)); % must be in repeating order
valsAll = [valsITD; valsILD]'; % this should represent all possible conditions

% randomly sample all unique pairs without replacement
presOrder = datasample(valsAll,length(valsAll),1,'Replace',false);

%% establish connection and set up arena
% set up the connection
portnumber = 4012;
VRconnection = tcpip('0.0.0.0',portnumber,'NetworkRole','server');
fprintf('Opening VRconnection, please connect to this server IP %s:%d\n',...
    char(java.net.InetAddress.getLocalHost.getHostAddress),portnumber);

fopen(VRconnection);
fprintf('Connected\n');

%configure the Unity program:
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

%% begin trials
for ii = 1:length(presOrder)
    % create stimuli based on specified condition
    switch condNum
        case 30
            [~,~,sig] = goStimTrain(0,0,0, ...
                presOrder(ii,1),presOrder(ii,2),1);
        case 50 % itd adaptor
            [~,~,sig] = goStimTrain(presOrder(ii,1),0,5, ...
                presOrder(ii,1),presOrder(ii,2),1);
        case 51 
            [~,~,sig] = goStimTrain(presOrder(ii,1),0,5, ...
                presOrder(ii,1),presOrder(ii,2),1);
        otherwise
            fprintf('Invalid condition!\nAborting\n\n');
            return 
    end
    
    % plot stimuli
    plot(sig(:,1),'b');
    hold on
    plot(sig(:,2),'r');
    hold off
    title(['ITD: ', num2str(presOrder(ii,1)), '; ILD: ', ...
        num2str(presOrder(ii,2))]);
        
    % record stimulus and id information for each trial
    data.condition(condNum).trials(ii,1,blockNum) = str2double(subject);
    data.condition(condNum).trials(ii,2,blockNum) = expNum;
    data.condition(condNum).trials(ii,3,blockNum) = condNum;
    data.condition(condNum).trials(ii,4,blockNum) = adaptorTypeNum;
    data.condition(condNum).trials(ii,5,blockNum) = presOrder (ii,1); % itd
    data.condition(condNum).trials(ii,6,blockNum) = presOrder (ii,2); % ild
    
    pause(ITI);
    
    ipmsg(VRconnection,'RESPAWN\n'); % replace destroyed balloon(s)
    ipmsg(VRconnection,'COLOR 0 GREEN\n'); % set 0 deg balloon to green
    
    % enable the homebox and change cursor
    ipmsg(VRconnection,'HOMEBOX ON\n');
    ipmsg(VRconnection,'GAZE ON\n');
    ipmsg(VRconnection,'ARMDISPLAY OFF\n');
    
    % wait for subject to put head in box before continuing trial
    fprintf('waiting...');
    waithome(VRconnection);
    fprintf('ready...');
    
    % disable homebox and change cursor during trial
    ipmsg(VRconnection,'HOMEBOX OFF\n');
    %ipmsg(VRconnection,'GAZE OFF\n');
    
    flush(VRconnection);
    
    % play stimulus and record send time
    sound(sig,FS);
    ipmsg(VRconnection,sprintf('COLOR 150 RED\n')); % any action to create Unity time stamp
    getInfo = textscan(fgetl(VRconnection),'%f%s%f','Delimiter','\t');
    sendTime = getInfo{1};
    data.condition(condNum).trials(ii,7,blockNum) = sendTime; % store sendTime
    data.condition(condNum).trials(ii,8,blockNum) = blockNum; % block number
  
    pause(1);
    
    % display stimulus information for trial
    fprintf('\n\tITD: %d\tILD: %d\tSent: %.2fs...',presOrder(ii,1),...
        presOrder(ii,2),sendTime);

    %ipmsg(VRconnection,'ARMDISPLAY ON\n');

    % get a response
    [respazim, resptime] = getresponse(VRconnection);
    fprintf('\n\tresponse (%.1f @ %.2fs)...',respazim,resptime); % report response

    % store response
    data.condition(condNum).trials(ii,8,blockNum) = respazim; % azimuth
    data.condition(condNum).trials(ii,9,blockNum) = resptime; % response time

    ipmsg(VRconnection,'ARMDISPLAY OFF\n'); % subject can respond now
    
    % feedback: pop selected balloon; bob if incorrect
    %if (azequals(targazim,round(respazim)))
        ipmsg(VRconnection,sprintf('VANISH %.1f\n',round(respazim)));
    %else
%         % wiggle the targeted balloon
%         ipmsg(VRconnection,sprintf('BOB %.1f % .1f -1\n',round(respazim),randn));
%         % flash the balloon's color
%         ipmsg(VRconnection,sprintf('COLOR %.1f WHITE\n',targazim));
%         pause(0.5);
%         ipmsg(VRconnection,sprintf('COLOR %.1f RED\n',targazim));
%     end
    fprintf('done\n');
end

pause(0.25);

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
Y = data.condition(condNum).trials(:,:,blockNum); % setup data matrix
goSurfaceModel2(Y,data.key(condNum));
  

%% disconnect        
ipmsg(VRconnection,'CLEAR ALL\n');
fprintf('\nFinished successfully.\nClosing connection... Goodbye!\n\n')

fclose(VRconnection);
delete(VRconnection);

end


%% ----------------------------- FUNCTIONS -----------------------------
%% azequals
% this function is only used for providing feedback
%
% function [result] = azequals(az1,az2)
% % function result = azequals(az1,az2)
% % same as equals but treats equivalent angles as equal
% 
% % transform to positive values 0-360
% while az1 < 0, az1 = az1+360; end
% while az1 >= 360, az1 = az1-360; end
% 
% while az2 < 0, az2 = az2+360; end
% while az2 >= 360, az2 = az2-360; end
% 
% result = (az1 == az2);
% end

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


