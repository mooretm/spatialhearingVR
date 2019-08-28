
[~,~,probe] = doRampedTones(500,0.5,0.02,270,0,48828);
figure

plot(probe(:,1)/max(probe(:,1)))
hold on 
plot(probe(:,2)/max(probe(:,2)))
hold off
xlim([0 length(probe)/10])
