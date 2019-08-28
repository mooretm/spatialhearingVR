function [randITDs, randILDs] = MOAscramble2()
% conds = {'ITD_m300';'ITD_m200';'ITD_m100';'ITD_0';'ITD_100'; ...
%     'ITD_200';'ITD_300'; ...
%     'ILD_m9';'ILD_m6';'ILD_m3';'ILD_0';'ILD_3';'ILD_6';'ILD_9'};

condsITD = {'ITD_m300';'ITD_m200';'ITD_m100';'ITD_0';'ITD_100'; ...
    'ITD_200';'ITD_300'};
condsILD = {'ILD_m6';'ILD_m3';'ILD_0';'ILD_3';'ILD_6'};

randITDs = datasample(condsITD,length(condsITD),1,'Replace',false)';
randILDs = datasample(condsILD,length(condsILD),1,'Replace',false)';

