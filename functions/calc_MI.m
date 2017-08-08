%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to produce a comodulogram of Phase Amplitude Coupling (PAC)
% Modulation Index (MI) values using the metrics from Tort et al.,(2010),
% Ozkurt & Schnitzler (2011), Canolty et al., (2006) and 
% PLV (Cohen 2008).
%
% Inputs:
% - virtsens = MEG data (1 channel)
% - toi = times of interest in seconds e.g. [0.3 1.5]
% - phases of interest e.g. [4 22] currently increasing in 1Hz steps
% - amplitudes of interest e.g. [30 80] currently increasing in 2Hz steps
% - diag = 'yes' or 'no' to turn on or off diagrams during computation
% - surrogates = 'yes' or 'no' to turn on or off surrogates during computation
% - approach = 'tort','ozkurt','canolty','PLV'
% Optional Inputs:
% - Number of phase bins used in KL-MI-Tort approach (default = 18)
%
% Outputs:
% - MI_matrix_raw = phase amplitude comodulogram (no surrogates)
% - MI_matrix_surr = = phase amplitude comodulogram (with surrogates)
%
% For details of the PAC methods go to:
% http://jn.physiology.org/content/104/2/1195.short
% http://science.sciencemag.org/content/313/5793/1626.long
% http://www.sciencedirect.com/science/article/pii/S0165027011004730
% http://www.sciencedirect.com/science/article/pii/S0165027007005237
%
% Written by: Robert Seymour - Aston Brain Centre. July 2017.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [MI_matrix_raw,MI_matrix_surr] = calc_MI(virtsens,toi,phase,amp,diag,surrogates,approach,varargin)

% Set number of bins used for Tort
if isempty(varargin)
    nbin = 18;
else
    fprintf('Number of bins set to %s',num2str(varargin{1}))
    nbin = varargin{1};
end

if diag == 'no'
    disp('NOT producing any images during the computation of MI')
end

% Determine size of final matrix
phase_length = length(phase(1):1:phase(2));
amp_length = length(amp(1):2:amp(2));

% Create matrix to hold comod
MI_matrix_raw = zeros(amp_length,phase_length);
MI_matrix_surr = zeros(amp_length,phase_length);
clear phase_length amp_length

row1 = 1;
row2 = 1;

for phase_freq = phase(1):1:phase(2)
    for amp_freq = amp(1):2:amp(2)
        %% Bandpass filter individual trials using a two-way Butterworth Filter
        
        % Specifiy bandwith = +- 2.5 * center frequency
        Af1 = round(amp_freq -(amp_freq/2.5)); Af2 = round(amp_freq +(amp_freq/2.5));
        
        % Filter data at phase frequency using Butterworth filter
        cfg = [];
        cfg.showcallinfo = 'no';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [phase_freq-1 phase_freq+1]; %+-1Hz - could be changed if necessary
        cfg.hilbert = 'angle';
        [virtsens_phase] = ft_preprocessing(cfg, virtsens);
        
        % Filter data at amp frequency using Butterworth filter
        cfg = [];
        cfg.showcallinfo = 'no';
        cfg.bpfilter = 'yes';
        cfg.bpfreq = [Af1 Af2];
        cfg.hilbert = 'abs';
        [virtsens_amp] = ft_preprocessing(cfg, virtsens);
        
        % Cut out window of interest - should exlude phase-locked
        % responses (e.g. ERPs)
        cfg = [];
        cfg.toilim = toi; %specfied in function calls
        cfg.showcallinfo = 'no';
        virtsens_phase_toi = ft_redefinetrial(cfg,virtsens_phase);
        virtsens_amp_toi = ft_redefinetrial(cfg,virtsens_amp);
        
        % Variable to hold MI for all trials
        MI_all_trials = [];
        
        % For each trial...
        for trial_num = 1:length(virtsens.trial)
            
            % Extract phase and amp info using hilbert transform
            Phase=virtsens_phase_toi.trial{1, trial_num}; % getting the phase
            Amp= virtsens_amp_toi.trial{1, trial_num}; % getting the amplitude envelope
            
            % Switch PAC method based on the approach
            switch approach
                case 'tort'
                    [MI] = calc_MI_tort(Phase,Amp,nbin);
                    
                case 'ozkurt'
                    [MI] = calc_MI_ozkurt(Phase,Amp);
                    
                case 'canolty'
                    [MI] = calc_MI_canolty(Phase,Amp);
                    
                case 'PLV'
                    [MI] = calc_MI_PLV(Phase,Amp);
            end
            
            % Add the MI value to all other all other values
            MI_all_trials(trial_num) = MI;
            
        end
        
        % If user specified to use surrogates - use them!
        if strcmp(surrogates, 'yes')
            
            % Variable to surrogate MI
            MI_surr = [];
            
            % For each surrogate (surrently hard-coded for 200, could be changed)...
            for surr = 1:200
                % Get 2 random trial numbers
                trial_num = randperm(length(virtsens_phase_toi.trialinfo),2);
                
                % Extract phase and amp info using hilbert transform
                % for different trials & shuffle phase
                Phase=virtsens_phase_toi.trial{1, trial_num(1)}(randperm(length(virtsens_phase_toi.trial{1,trial_num(1)}))); % getting the phase
                Amp = virtsens_amp_toi.trial{1,trial_num(2)};
                
                % Switch PAC approach based on user input
                
                switch approach
                    
                    case 'tort'
                        [MI] = calc_MI_tort(Phase,Amp);
                        
                    case 'ozkurt'
                        [MI] = calc_MI_ozkurt(Phase,Amp);
                        
                    case 'canolty'
                        [MI] = calc_MI_canolty(Phase,Amp);
                        
                    case 'PLV'
                        [MI] = calc_MI_PLV(Phase,Amp);
                end
                
                % Add this value to all other all other values
                MI_surr(surr) = MI;
            end
            
            % Calculate average MI over trials
            MI_raw = mean(MI_all_trials);
            
            % Subtract the mean of the surrogaates from the actual PAC
            % value and add this to the surrogate matrix
            MI_surr_normalised = MI_raw-mean(MI_surr);
            MI_matrix_surr(row1,row2) = MI_surr_normalised;
            
        end
        
        % Calculate the raw MI score (no surrogates) and add to the matrix
        MI_raw = mean(MI_all_trials);
        MI_matrix_raw(row1,row2) = MI_raw;
        
        % Show progress of the comodulogram if diag = 'yes'
        if strcmp(diag, 'yes')
            figure(2)
            pcolor(phase(1):1:phase(2),amp(1):2:amp(2),MI_matrix_raw)
            colormap(jet)
            ylabel('Amplitude (Hz)')
            xlabel('Phase (Hz)')
            colorbar
            drawnow
        end
        
        % Go to next Amplitude
        row1 = row1 + 1;
        
        (fprintf('Phase: %d Amplitude: %d  MI: %d',phase_freq,amp_freq,MI_raw));
        
    end

    % Go to next Phase
    row1 = 1;
    row2 = row2 + 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PAC SUB-FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [MI] = calc_MI_tort(Phase,Amp,nbin)
        
        % Apply Tort et al (2010) approach)
        %nbin=18; % % we are breaking 0-360o in 18 bins, ie, each bin has 20o
        position=zeros(1,nbin); % this variable will get the beginning (not the center) of each bin 
        % (in rads)
        winsize = 2*pi/nbin;
        for j=1:nbin
            position(j) = -pi+(j-1)*winsize;
        end
        
        % now we compute the mean amplitude in each phase:
        MeanAmp=zeros(1,nbin);
        for j=1:nbin
            I = find(Phase <  position(j)+winsize & Phase >=  position(j));
            MeanAmp(j)=mean(Amp(I));
        end
        
        % The center of each bin (for plotting purposes) is
        % position+winsize/2
        
        % Plot the result to see if there's any amplitude modulation
        if strcmp(diag, 'yes')
            bar(10:20:720,[MeanAmp,MeanAmp]/sum(MeanAmp),'phase_freq')
            xlim([0 720])
            set(gca,'xtick',0:360:720)
            xlabel('Phase (Deg)')
            ylabel('Amplitude')
        end
        
        % Quantify the amount of amp modulation by means of a
        % normalized entropy index (Tort et al PNAS 2008):
        
        MI=(log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);
    end

    function [MI] = calc_MI_ozkurt(Phase,Amp)
        % Apply the algorithm from Ozkurt et al., (2011)
        N = length(Amp);
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = (1./sqrt(N)) * abs(mean(z)) / sqrt(mean(Amp.*Amp)); % Normalise
    end

    function [MI] = calc_MI_PLV(Phase,Amp)
        % Apply PLV algorith, from Cohen et al., (2008)
        amp_phase = angle(hilbert(detrend(Amp))); % Phase of amplitude envelope
        MI = abs(mean(exp(1i*(Phase-amp_phase))));
    end

    function [MI] = calc_MI_canolty(Phase,Amp)
        % Apply MVL algorith, from Canolty et al., (2006)
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = abs(mean(z));
    end

end
