function doRampedTonesTest
%function doRampedTonesTest
%
%  Automate testing of doRampedTones.m script. Generate a variety
%    of ITDs, ILDs and combinations. Return plots and diagnostic
%    information (e.g., rms values, delay in samples and ITD, etc.).
%
%  Author: Travis Moore
%  Last updated: 9 February 2018
%
%% Define conditions to test
    cf = [repmat(500,1,10),repmat(1000,1,4)];
    dur = repmat(0.2,1,14);
    rampdur = dur*0.1;
    itd = [0,0,0,0,7200,-7200,90,-90,180,-180,90,-90,270,-270];
    ild = [1.5,6,-1.5,-6,0,0,0,0,0,0,-1,1,-6,6];
    fs = repmat(48000,1,14);
    
    tests = [cf; dur; rampdur; itd; ild; fs]';

%% Loop through all test conditions
    for ii = 1:length(tests)
        [~,~,sigBoth] = doRampedTones(cf(ii),dur(ii), ...
            rampdur(ii),itd(ii),ild(ii),fs(ii));
        fprintf('\nTest %d: CF = %d, ITD = %d, ILD = %d\n', ...
            ii,cf(ii),itd(ii),ild(ii));
        fprintf('Magnitude:\n')
        fprintf('Left: %d, Right: %d, Diff: %d\n', ...
            rms(sigBoth(:,1)),rms(sigBoth(:,2)), ...
                round(rms(sigBoth(:,1)) - rms(sigBoth(:,2)),4));
        fprintf('dB:\n');
        fprintf('Left: %d, Right: %d, Diff: %d\n\n', ...
            mag2db(rms(sigBoth(:,1))),mag2db(rms(sigBoth(:,2))), ...
                mag2db(rms(sigBoth(:,1))) - mag2db(rms(sigBoth(:,2))));
        pause;
    end

end

