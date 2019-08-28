function [rando1 rando2] = MOAscramble()
% conds = {'ITD_m300';'ITD_m200';'ITD_m100';'ITD_0';'ITD_100'; ...
%     'ITD_200';'ITD_300'; ...
%     'ILD_m9';'ILD_m6';'ILD_m3';'ILD_0';'ILD_3';'ILD_6';'ILD_9'};

conds = {'ITD_m300';'ITD_m200';'ITD_m100';'ITD_0';'ITD_100'; ...
    'ITD_200';'ITD_300';'ILD_m6';'ILD_m3';'ILD_0';'ILD_3';'ILD_6'};

rando = datasample(conds,length(conds),1,'Replace',false);

rando1 = rando(1:6)';
rando2 = rando(7:12)';

