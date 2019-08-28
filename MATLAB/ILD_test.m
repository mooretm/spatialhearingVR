
% create sine wave
theILD = 3;
%[left, right, both] = doRampedTones_troubleshooting(500,0.2,0.01,270,theILD,48000);
[left, right, both] = doRampedTones(500,0.2,0.01,270,theILD,48000);

fprintf('\nILD: %.1f', theILD);

fprintf('\nleft rms (dB): %.3f', ...
    mag2db(rms(left)));
fprintf('\nright rms (dB): %.3f', ...
    mag2db(rms(right)));

diff = mag2db(rms(right)) - mag2db(rms(left));
fprintf('\ndifference rms (dB): %.3f', ...
    diff);

fprintf('\nAt transducer: %.3f\n', ...
    diff + 0.6);


