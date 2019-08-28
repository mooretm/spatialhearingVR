function [adaptor, probe, train] = goStimTrain(adaptITD,adaptILD, ...
    adaptReps,probeITD,probeILD,probeReps)
%function [adaptor probe train] = goStimTrain(freq,dur,rampdur, ...
%    adaptITD,adaptILD,adaptNum,probeITD,probeILD,probeNum,ISI)
%
%GOSTIMTRAIN: Create a stimulus train consisting of ADAPTNUM number of 
%             adaptors and PROBENUM number of probes. Stimuli are 
%             created by providing ADAPTITD/ILD and PROBEITD/ILD values.
%             Time between presentations is set to ISI number of seconds.
%
%    adaptITD: delay of adaptor stimulus, in microseconds
%    adaptILD: level difference of adaptor stimulus, in dB
%    adaptNum: number of adaptors to include
%    probeITD: delay of probe stimulus, in microseconds
%    probeILD: level difference of probe stimulus, in dB
%    probeNum: number of probes to include
%    ISI: interstimulus interval, in seconds
%
%    EXAMPLE: 
%
%    Author: Travis Moore
%    Last updated: 12 February 2018

%% Initialize defaults
FREQ = 500; % stimulus frequency in Hz
FS = 48828; % sampling rate
DUR = 0.5; % stimulus duration in seconds
RAMPDUR = 0.02; % ramp duration (on/off gating) in seconds
ISI = 0.4; % interstimulus interval in seconds

% shortened ISI and DUR testing
%DUR = 0.2;
%ISI = 0;


%% Make train
[~,~,adaptor] = doRampedTones(FREQ,DUR,RAMPDUR,adaptITD,adaptILD,FS);
[~,~,probe] = doRampedTones(FREQ,DUR,RAMPDUR,probeITD,probeILD,FS);
silence = zeros(round(ISI*FS),2); % ISI in samples
adaptor = vertcat(adaptor,silence);
probe = vertcat(probe,silence);

train = [repmat(adaptor,adaptReps,1);repmat(probe,probeReps,1)];

end
