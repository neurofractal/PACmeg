%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 4_calc_pow_change.m
%
% This is a Matlab script to compute the % change in power from 1-100Hz
% within the V1 virtual electrode
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load computer-specific information
PAC_frontiers_dir;
addpath(fieldtrip_dir);
ft_defaults

%% Subject List
subject = sort({'RS','DB','MP','GR','DS','EC','VS','LA','AE','SY','GW',...
    'SW','DK','LH','KM','FL','AN','KT'});

%% Create figure to be used
figure; hold on; perc_change_all = [];

%% start loop for each subject
for i = 1:length(subject)
    
    % cd to the right place and load the V1 virtual electrode
    cd(sprintf('D:\\scripts\\PAC_for_frontiers\\%s\\',subject{i}))
    load('VE_V1.mat');
    
    % Calculate Power in Grating & Baseline Periods
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.foi = 1:1:100; %1-100Hz
    cfg.toi = 0.3:0.02:1.5; %300-1200ms period
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
    multitaper_post = ft_freqanalysis(cfg, VE_V1);
    cfg.toi = -1.5:0.02:-0.3; %change time-window
    multitaper_pre = ft_freqanalysis(cfg, VE_V1);
    
    % Calculate % change by averaging over time
    perc_change = (squeeze(mean(multitaper_post.powspctrm,3))...
        -  squeeze(mean(multitaper_pre.powspctrm,3)));
    perc_change(:,:) = perc_change(:,:)./squeeze(mean(multitaper_pre.powspctrm,3))
    perc_change(:,:) = perc_change(:,:)*100;
    
    % Add to array outside the loop
    perc_change_all(i,:) = perc_change;
    
    % Add the line to the figure
    hold on;
    plot([1:1:100],perc_change,'LineWidth',3);
    
end

%% Add overall mean % change to graph in black and add information to the graph
average_change = mean(perc_change_all);
hold on;
plot([1:1:100],average_change,'-k','LineWidth',6);
ylabel('% Power Change');
xlabel('Frequency (Hz)');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
