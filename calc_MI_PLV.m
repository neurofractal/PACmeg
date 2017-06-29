%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to calculate a comodulogram of Modulation Index (MI) values
% from Fieldtrip data using the PLV metric from Cohen et al., (2008)
%
% Inputs: 
% - virtsens = MEG data (1 channel)
% - toi = times of interest in seconds e.g. [0.3 1.5]
% - phases of interest e.g. [4 22] currently increasing in 1Hz steps
% - amplitudes of interest e.g. [30 80] currently increasing in 2Hz steps
% - diag = 'yes' or 'no' to turn on or off diagrams during computation
%
% For details of the method please see:
% http://www.sciencedirect.com/science/article/pii/S0165027007005237
%
% Written by Robert Seymour (Aston Brain Centre)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [MI_matrix] = calc_MI_PLV(virtsens,toi,phase,amp,diag)

if diag == 'no'
    disp('NOT producing any images during the computation of MI')
end

% Determine size of final matrix
phase_length = length(phase(1):1:phase(2));
amp_length = length(amp(1):2:amp(2));

% Create matrix to hold comod
MI_matrix = zeros(amp_length,phase_length);
clear phase_length amp_length

row1 = 1;
row2 = 1;

for k = phase(1):1:phase(2) 
    for p = amp(1):2:amp(2) 
        %% Bandpass filter individual trials usign a two-way Butterworth Filter
     
        % Specifiy bandwith = +- 1/3 of center frequency
        Af1 = round(p -(p/2.5)); Af2 = round(p +(p/2.5));
         
        % Filter data at phase frequency using Butterworth filter
        cfg = [];
        cfg.showcallinfo = 'no';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [k-1 k+1]; %+-1Hz - could be changed
        cfg.hilbert = 'angle';
        [virtsens_phase] = ft_preprocessing(cfg, virtsens);
        
        % Filter data at amp frequency using Butterworth filter
        cfg = [];
        cfg.showcallinfo = 'no';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [Af1 Af2];
        cfg.hilbert = 'abs';
        [virtsens_amp] = ft_preprocessing(cfg, virtsens);

         % Cut out window of interest (phase) - should exlude phase-locked
        % responses (e.g. ERPs)
        cfg = [];
        cfg.toilim = toi; %specfied in function calls
        cfg.showcallinfo = 'no';
        post_grating_phase = ft_redefinetrial(cfg,virtsens_phase);
        post_grating_amp = ft_redefinetrial(cfg,virtsens_amp);
        
        % Variable to hold MI for all trials
        MI_comb = [];

        
        % For each trial...
        for trial_num = 1:length(virtsens.trial)
            
            % Extract phase and amp info using hilbert transform
            Phase= post_grating_phase.trial{1, trial_num}; % getting the phase
            Amp= post_grating_amp.trial{1, trial_num}; % getting the amplitude envelope
            
            % Apply PLV algorith, from Cohen et al., (2008)
            amp_phase = angle(hilbert(detrend(Amp))); 
            MI = abs(mean(exp(1i*(Phase-amp_phase))));
            
            % Add this value to all other all other values
            MI_comb(trial_num) = MI;
            
        end
        
        % Calculate average MI over trials
        MI_comb = mean(MI_comb);
        
        % Add to Matrix
        MI_matrix(row1,row2) = MI_comb;
        
        % Show progress of the comodulogram
        if strcmp(diag, 'yes')
            figure(2)
            pcolor(phase(1):1:phase(2),amp(1):2:amp(2),MI_matrix)
            colormap(jet)
            ylabel('Amplitude (Hz)')
            xlabel('Phase (Hz)')
            colorbar
            drawnow
        end

        % Go to next Amplitude
        row1 = row1 + 1;
        
        disp(sprintf('Phase: %d Amplitude: %d  MI: %d',k,p,MI_comb));
    end
    % Go to next Phase
    row1 = 1;
    row2 = row2 + 1;
end
end