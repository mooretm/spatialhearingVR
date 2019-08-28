function [sigLeft, sigRight, sigBoth] = doRampedTones(cf,dur,rampdur,itd,ild,fs)
%function [sigLeft, sigRight, sigBoth] = doRampedTones(cf,dur,rampdur,itd,ild,fs)
%
%DORAMPEDTONES generate two ramped tones with a specified itd
%
%   cf = carrier frequency in Herz
%   dur = stimulus duration in seconds
%   rampdur = ramp duration in seconds
%   itd = delay between L/R channels in microseconds
%   ild = level difference between L/R channels
%   fs = sampling rate
%
%   Example: [left, right, both] = doRampedTones(500,0.2,0.01,270,-1,48000);
%
%   Authors: Travis Moore, Chris Stecker
%   Last updated: 9 February 2018
%

%% convert user-friendly function parameter units to useful units
cf = cf / fs; %cycles per second --> cycles per sample
dur = round(dur * fs); %stim duration in seconds --> stim duration in samples
rampdur = round(rampdur * fs); %ramp duration in seconds --> duration in samples
%itd = round(fs * itd / 1000000); %delay in microseconds --> delay in samples
itd = fs * itd / 1000000; % unrounded samples
level = -25.5; % start at a low level to avoid clipping
offset = 0.6; % account for difference between insert earphones

%% create time vectors
fulldur = ceil(dur + abs(itd));
%t = ((1:fulldur)-(fulldur/2)); % timebase for computing clicks
t = 0:(fulldur-1);
tlead = t - itd/2; % time vector for leading signal
tlag = t + itd/2; % time vector for lagging signal

%% make ramped filter
tRamp = 0:(rampdur - 1);
rampup = cos(linspace(pi/2,0,rampdur)).^2;
rampdown = cos(linspace(0,pi/2,rampdur)).^2;

tRamp = 0:(rampdur - 1);
tRampLong = -5:rampdur+4;
rampup = [zeros(1,5) cos(linspace(pi/2,0,rampdur)).^2 ones(1,5)];
rampdown = [ones(1,5) cos(linspace(0,pi/2,rampdur)).^2 zeros(1,5)];

rampupLead = interp1(tRampLong,rampup,tRamp+itd/2,'linear','extrap');
rampupLag = interp1(tRampLong,rampup,tRamp-itd/2,'linear','extrap');

rampdownLead = interp1(tRampLong,rampdown,tRamp+itd/2,'linear','extrap');
rampdownLag = interp1(tRampLong,rampdown,tRamp-itd/2,'linear','extrap');
%silence = zeros(1,abs(round(itd/2))); % this is how I am shifting the window in time

% if itd < 0
%     windowLeftChan = [rampup ...
%         ones(1,fulldur-(2*rampdur+length(silence))) rampdown silence];
%     windowRightChan = [silence rampup ...
%         ones(1,fulldur-(2*rampdur+length(silence))) rampdown];
% else
%     windowRightChan = [rampup ...
%         ones(1,fulldur-(2*rampdur+length(silence))) rampdown silence];
%     windowLeftChan = [silence rampup ...
%         ones(1,fulldur-(2*rampdur+length(silence))) rampdown];
% end

if itd < 0
    windowLeftChan = [rampupLead, ones(1,fulldur-(2*rampdur)), rampdownLead];
    windowRightChan = [rampupLag, ones(1,fulldur-(2*rampdur)), rampdownLag];
else
    windowLeftChan = [rampupLag, ones(1,fulldur-(2*rampdur)), rampdownLag];
    windowRightChan = [rampupLead, ones(1,fulldur-(2*rampdur)), rampdownLead];
end

    

%% make stimuli
%%% LEFT channel %%%
sigLeft = db2mag(level) * sin(2*pi*cf*tlead) .* windowLeftChan;
sigLeft = sigLeft';

%%% RIGHT channel %%%
sigRight = db2mag(level-offset) * sin(2*pi*cf*tlag) .* windowRightChan;
sigRight = sigRight';

% apply ILD
if ild < 0
    sigLeft = sigLeft .* db2mag(abs(ild/2));
    sigRight = sigRight ./ db2mag(abs(ild/2));
else
    sigLeft = sigLeft ./ db2mag(abs(ild/2));
    sigRight = sigRight .* db2mag(abs(ild/2));
end

%%% make stereo stimulus (final product) %%%
sigBoth = [sigLeft sigRight; zeros(1000,2)];

%% plot the stimuli
% subplot(4,1,1)
%     plot(sigLeft,...
%         'LineWidth',1,...
%         'Color','blue')
%     ylabel('Amplitude')
%     title('Left Channel')
% subplot(4,1,2)
%     plot(sigRight,...
%         'LineWidth',1,...
%         'Color','red')
%     ylabel('Amplitude')
%     title('Right Channel')
% subplot(4,1,3)
%     plot(sigLeft,...
%         'LineWidth',1,...
%         'Color','blue')
%     hold on
%     plot(sigRight,...
%         'LineWidth',1,...
%         'Color','red')
%     hold off
%     ylabel('Amplitude')
%     title('Stereo Stimulus')
% subplot(4,1,4)
%     envelope(sigBoth);
%     ylabel('Amplitude')
%     xlabel('Time')
    