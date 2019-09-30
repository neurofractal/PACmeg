function [MI_matrix_raw] = PACmeg(cfg,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PACmeg: a function to do PAC
%
% Author: Robert Seymour (robert.seymour@mq.edu.au)
%
%%%%%%%%%%%
% Inputs:
%%%%%%%%%%%
%
% - data            = data for PAC (2D matrix)
% cfg.Fs            = Sampling frequency (in Hz)
% cfg.phase_freqs   = Phase Frequencies in Hz (e.g. [8:1:13])
% cfg.amp_freqs     = Amplitude Frequencies in Hz (e.g. [40:2:100])
% cfg.method        = Method for PAC Computation:
%                   ('Tort','Ozkurt','PLV','Canolty)
%
%%%%%%%%%%%
% Outputs:
%%%%%%%%%%%
%
% - output_1    = ...
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Get function inputs
% Get sampling frequency
Fs = ft_getopt(cfg,'Fs',[]);

if isempty(Fs)
    error('Please Specify cfg.Fs');
elseif ~isnumeric(Fs)
    error('cfg.Fs needs to be numeric (e.g. 1000)');
end

% Get phase frequencies
phase_freqs = ft_getopt(cfg,'phase_freqs',[]);

if isempty(phase_freqs)
    error('Please Specify cfg.phase_freqs');
end

% Get amplitude frequencies
amp_freqs = ft_getopt(cfg,'amp_freqs',[max(phase_freqs):2:Fs/2]);

% Get PAC Method
method = ft_getopt(cfg,'method','tort');
fprintf('Using the %s method for PAC computation\n',method);

%% Check inputs

% Check whether the inouts are numbers(!)
if ~floor(phase_freqs) == phase_freqs
    error('Numeric Values ONLY for Phase');
end

if ~floor(amp_freqs) == amp_freqs
    ft_error('Numeric Values ONLY for Amplitude');
end

% Check whether PAC can be detected
if min(amp_freqs)/2.5 < max(phase_freqs)
    try
        low_amp = min(amp_freqs(find(amp_freqs/2.5 > max(phase_freqs))));
    catch
        low_amp = '?';
    end
    
    error(['Your amplitude range extends too low. Reduce the phase to ' ...
        num2str(min(amp_freqs)/2.5) 'Hz, or increase the amplitude to '...
        num2str(low_amp) 'Hz']);
end


%% Filter Phase Frequencies & take 'angle'
disp('Filtering Phase...');

phase_filtered = zeros(length(phase_freqs),length(data));

for phase = 1:length(phase_freqs)
    
    [filt] = ft_preproc_bandpassfilter(data, Fs,...
        [phase_freqs(phase)-1 phase_freqs(phase)+1],...
        4, 'but', 'twopass', 'no');
    
    phase_filtered(phase,:) = ft_preproc_hilbert(filt, 'angle');
    clear filt
end

%% Filter Amplitude & Take 'abs'
disp('Filtering Amplitude...');

amp_filtered = zeros(length(amp_freqs),length(data));

for amp = 1:length(amp_freqs)
    
    %     Af1 = round(amp_freqs(amp) -(amp_freqs(amp)/2.5));
    %     Af2 = round(amp_freqs(amp) +(amp_freqs(amp)/2.5));
    
    Af1 = amp_freqs(amp) - 2.0*max(phase_freqs);
    Af2 = amp_freqs(amp) + 2.0*max(phase_freqs);
    
    [filt] = ft_preproc_bandpassfilter(data, Fs,...
        [Af1 Af2],4, 'but', 'twopass', 'no');
    
    amp_filtered(amp,:) = ft_preproc_hilbert(filt, 'abs');
    clear filt Af1 Af2
end


%% PAC computation
MI_matrix_raw = zeros(length(amp_freqs),length(phase_freqs));

for phase = 1:length(phase_freqs)
    for amp = 1:length(amp_freqs)
        
        % Switch based on the method of PAC computation
        switch method
            case 'tort'
                
                [MI] = calc_MI_tort(phase_filtered(phase,:),...
                    amp_filtered(amp,:),18);
                
            case 'ozkurt'
                [MI] = calc_MI_ozkurt(phase_filtered(phase,:),...
                    amp_filtered(amp,:));
                
            case 'PLV'
                [MI] = cohen_PLV(phase_filtered(phase,:),...
                    amp_filtered(amp,:));
                
            case 'canolty'
                [MI] = calc_MI_canolty(phase_filtered(phase,:),...
                    amp_filtered(amp,:));
                
        end
        
        % Add to matrix outside the loop
        MI_matrix_raw(amp,phase) = MI;
    end
end

end

