%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 6_check_non_sinusoidal.m
%
% Script to check for non-sinusoidal oscillations in the phase of lower
% frequency oscillations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath
sensory_PAC;
addpath(fieldtrip_dir);
ft_defaults

% If you do not run these lines you will have to manually specify:
% - subject = subject list
% - data_dir = directory which contains the MEG & anatomical information
% - scripts_dir = directory with ALL the scripts
% - fieldtrip_dir = directory containing the Fieldtrip toolbox

%% Concatenate all VE data into single variable
VE_V1_concat = [];

% Start loop for all subjects
for sub = 1:length(subject)

    % Load in data
    load([scripts_dir '\' subject{sub} '\VE_V1.mat']);
    
    % Append
    if sub == 1
        VE_V1_concat = VE_V1;
    else
        cfg = [];
        VE_V1_concat = ft_appenddata(cfg,VE_V1_concat,VE_V1);
    end
end

%% Calculate the Rise Time: Decay Time for Gratig & Baseline Periods

stats_all = []; % Variable to hold the output from the t-test
p_all = []; % Variable to hold the p-value from the t-test
count = 1; % For use wthin the loop
figure; % Create figure

% Start loop for phases 7-13Hz
for phase = 7:13
    
    % Use check_non_sinusoidal_rise_decay function for grating and baseline
    % periods
    [ratios_post_grating,time_to_decay_all,time_to_peak_all] = ...
        check_non_sinusoidal_rise_decay(VE_V1,[0.3 1.5],phase);
    [ratios_pre_grating,time_to_decay_all,time_to_peak_all] = ...
        check_non_sinusoidal_rise_decay(VE_V1,[-1.5 -0.3],phase);
    
    % Create two overalpping histograms and add to subplot
    subplot(2,4,count); histogram(ratios_post_grating); hold on; 
    histogram(ratios_pre_grating);
    xlabel('Time to Peak:Decay'); ylabel('Count'); 
    legend({'Ratio Pre-Grating' 'Ratio Post-Grating'});
    
    % Do a t-test to check for difference between ratio values pre &
    % post-grating
    [h,p,ci,stats] = ttest(ratios_post_grating,ratios_pre_grating);
    title(['Phase Frequency = ' num2str(phase)  ' ; p = ' num2str(p)]);
    
    % Add this to the varibles outsode the loop for all phases
    stats_all{count} = stats;
    p_all(count) = p;
    count = count+1;
    
    disp(['Phase ' num2str(phase)]);
end


