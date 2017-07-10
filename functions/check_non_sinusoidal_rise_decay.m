%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% check_non_sinusoidal_rise_decay.m
%
% Function to check for non-sinusoidal / sawtooth oscillations by calculating
% the ratio between rise-time and decay time. If ratio is uneven this 
% implies that the oscillation is non-sinusoidal/sawtooth-like.
%
% Inputs:
% - virtsens = virtual sensor data from Fieldtrip
% - toi = times of interest (make this shorter than your epoch length to
% avoid edge artefacts
% - phase_freq = phase of interest
%
% Outputs:
% - ratios = array of N trials with ratio between time to peak and time to
% decay
% - time_to_decay_all = times (in ms) of EVERY peak-->trough event 
% - time_to_peak_all = times of EVERY trough-->peak event
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ratios,time_to_decay_all,time_to_peak_all] = check_non_sinusoidal_rise_decay(virtsens,toi,phase)

% 
% % Filter data at phase frequency using Butterworth filter
cfg = [];
cfg.showcallinfo = 'no';
cfg.bpfilter = 'yes';
cfg.bpfreq = [phase-1 phase+1]; % Can be widened if necessary
[phase] = ft_preprocessing(cfg, virtsens);

% Extract times of interest
cfg = [];
cfg.toilim = toi;
cfg.showcallinfo = 'no'; %specfied in function calls
phase_toi = ft_redefinetrial(cfg,phase);

% Book-keeping
ratios = zeros(1,length(virtsens.trial)); %variable to hold time_to_decay:time_to_peak for all trials
time_to_decay_all = []; %variable to hold time_to_decay for all trials
time_to_peak_all = [];
p = 1;

%% For every trial number calculate Calculate time to peak and time to decay

for trial_num = 1:length(virtsens.trial)
    % Get the time series (for peaks) and flipped time series (for troughs)
    trial = phase_toi.trial{1,trial_num}; trialflipped = trial.*-1;
    
    % Find peaks & troughs
    [~,peak_locations] = findpeaks(trial);
    [~,trough_locations] = findpeaks(trialflipped);
    
    % Equalise the number of peak and trough events
    if length(peak_locations) > length(trough_locations)
        peak_locations(1) = [];
    elseif length(peak_locations) < length(trough_locations)
        trough_locations(1) = [];
    end
    
    % Calculate time to peak and time to decay
    time_to_decay = [];
    time_to_peak = [];
    
    if peak_locations(1)<trough_locations(1) %if peak first
        
        for i = 1:length(peak_locations)-1
            time_to_decay(i) = trough_locations(i)-peak_locations(i);
            time_to_decay_all(p) = trough_locations(i)-peak_locations(i);
            time_to_peak(i) = abs(peak_locations(i+1)-trough_locations(i));
            time_to_peak_all(p) = abs(peak_locations(i+1)-trough_locations(i));
            p = p+1;
        end
    
    
    elseif peak_locations(1)>trough_locations(1) %if trough first
        
        for i = 1:length(peak_locations)-1
            time_to_decay(i) = peak_locations(i)-trough_locations(i);
            time_to_decay_all(p) = peak_locations(i)-trough_locations(i);
            time_to_peak(i) = abs(trough_locations(i+1)-peak_locations(i));
            time_to_peak_all(p) = abs(trough_locations(i+1)-peak_locations(i));
            p = p+1;
        end
    end
    
    % Calculate ratio and add to ratios variable
    ratios(trial_num) = mean(time_to_decay)./mean(time_to_peak);
end
      


