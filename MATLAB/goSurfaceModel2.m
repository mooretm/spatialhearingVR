function goSurfaceModel2(obs,plotTitle)
%function goSurfaceModel2(obs,plotTitle)
%
%  Create a surface model for psychophysical responses based on mixtures of
%  ITD and ILD. ITD is plotted along the X-axis, and ILD along the Y-axis.
%  The X and Y axes create a matrix of the conditions tested (i.e., every
%  ITD value that was tested at every ILD value). Colors represent the
%  magnitude of a subject's response.
%
%  Other versions of this script DEPEND ON: paste.m
%
%    ARGUMENTS
%    obs: raw data matrix from goBalloons.m, extracted from the data
%      structure using doDataCrawler.m or similar.
%    plotTitle: description of what is being plotted
%
%  Author: Travis Moore
%  Date: 6/8/2017
%  Last edited: 8/31/2017


%% extract and sort (ascending) ITDs and ILDs for plotting
itdsRaw = obs(:,5); % itds in original presentation order
itdsUnique = unique(sort(itdsRaw))'; % x axis values (sorted, unique)
ildsRaw = obs(:,6);
ildsUnique = unique(sort(ildsRaw))';

% format ITD and ILD values into condition matrices
itdVector = repmat(itdsUnique,1,length(ildsUnique))';
itdMatrix = reshape(itdVector,length(itdsUnique),length(ildsUnique))';

ildVector = sort(repmat(ildsUnique,1,length(itdsUnique)))';
ildMatrix = reshape(ildVector,length(itdsUnique),length(ildsUnique))';

%% plotting
% make a plot of raw values for double-checking the accuracy of the
% plot/data manipulations
figure
plot(itdMatrix,ildMatrix,'wo')
title('Check yo'' self')
xlabel('ITD (\mus)')
xlim([(min(itdsRaw)-100),(max(itdsRaw)+100)]);
set(gca,'xtick',itdsUnique)
ylabel('ILD (dB)')
set(gca,'ytick',ildsUnique)
hold on

for i = 1:length(itdsRaw)
    text(itdsRaw(i),ildsRaw(i),num2str(obs(i,8)));
end

% reshape obs for surface modeling (matrix format)
cols = sortrows(obs,5:6);
resp = cols(:,8);
respMatrix = vec2mat(resp,length(itdsUnique))';

% plot surface model in 2D and 3D
% 3D
figure
subplot(1,2,1)
surface(itdMatrix,ildMatrix,respMatrix)
xlabel('ITD (\mus)')
set(gca,'xtick',itdsUnique)
ylabel('ILD (dB)')
set(gca,'ytick',ildsUnique)
zlabel('Azimuth (deg)')
view(3) % 3D view
title(plotTitle,'Interpreter','none')

% 2D
subplot(1,2,2)
surface(itdMatrix,ildMatrix,respMatrix)
xlabel('ITD (\mus)')
set(gca,'xtick',itdsUnique)
ylabel('ILD (dB)')
set(gca,'ytick',ildsUnique)
zlabel('Azimuth (deg)')
view(2) % 2D view
title(plotTitle,'Interpreter','none')
%mesh(itd,ild,p)
%surf(itd,ild,p)

% datacursormode on
% dcm_obj = datacursormode
% set(dcm_obj,'Enable','on')
% disp('Click a point to see a plot, then press Return.')
% pause
% c_info = getCursorInfo(dcm_obj)
% disp(c_info)

