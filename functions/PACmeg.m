function [MI_matrix_raw,MI_matrix_surr] = PACmeg(cfg,data)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PACmeg: a function to perform phase amplitude coupling analysis
%
% Author: Robert Seymour (rob.seymour@ucl.ac.uk) April 2020
%
% Requirements: 
% - MATLAB 2016b or later
% - Fieldtrip Toolbox
% - PACmeg
%
%%%%%%%%%%%
% Inputs:
%%%%%%%%%%%
%
% data              = data for PAC (size: trials*time)
% cfg.Fs            = Sampling frequency (in Hz)
% cfg.phase_freqs   = Phase Frequencies in Hz (e.g. [8:1:13])
% cfg.amp_freqs     = Amplitude Frequencies in Hz (e.g. [40:2:100])
% cfg.filt_order    = Filter order used by ft_preproc_bandpassfilter
%
% amp_bandw_method  = Method for calculating bandwidth to filter the 
%                   ampltitude signal:
%                        - 'number': +- nHz either side
%                        - 'maxphase': 1.5*max(phase_freq)
%                        - 'centre_freq': +-2.5*amp_freq
% amp_bandw         = Bandwidth when cfg.amp_bandw_method = 'number'; 
%
% cfg.method        = Method for PAC Computation:
%                   ('tort','ozkurt','plv','canolty)
%
% cfg.surr_method   = Method to compute surrogates:
%                        - '[]': No surrogates
%                        - 'swap_blocks': cuts each trial's amplitude at 
%                        a random point and swaps the order around
%                        - 'swap_trials': permutes phase and amp from
%                        different trials
% cfg.surr_N        = Number of iterations used for surrogate analysis
%
% cfg.mask          = filters ALL data but masks between times [a b]
%                   (e.g. cfg.mask = [100 800]; will 
%
% cfg.avg_PAC       = Average PAC over trials ('yes' or 'no')
%
%%%%%%%%%%%
% Outputs:
%%%%%%%%%%%
%
% - MI_matrix_raw   = comodulagram matrix (size: amp*phase)
% - MI_matrix_surr  = surrogate comodulagram matrix (size: surr*amp*phase)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Check if Fieldtrip is in the MATLAB path
try
    ft_defaults;
catch
    error('Add Fieldtrip to your MATLAB path');
end

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

% Get filter order
filt_order = ft_getopt(cfg,'filt_order',4);

% Get amplitude bandwidth method
amp_bandw_method = ft_getopt(cfg,'amp_bandw_method','maxphase');
amp_bandw = ft_getopt(cfg,'amp_bandw',10);

% Get PAC Method
method = ft_getopt(cfg,'method','tort');
fprintf('Using the %s method for PAC computation\n',method);

% Get Masking
mask = ft_getopt(cfg,'mask',[]);

% Get surrogate method, number of iterations and seed
surr_method = ft_getopt(cfg,'surr_method',[]);
surr_N      = ft_getopt(cfg,'surr_N',200);
surr_seed   = ft_getopt(cfg,'surr_seed',[]);

% Get option for whether to average PAC over trials
avg_PAC = ft_getopt(cfg,'avg_PAC','yes');

%% Check inputs

% Check whether the inputs are numbers(!)
if ~floor(phase_freqs) == phase_freqs
    error('Numeric Values ONLY for Phase');
end

if ~floor(amp_freqs) == amp_freqs
    ft_error('Numeric Values ONLY for Amplitude');
end

% Give user a warning if using low-frequencies for phase
if min(phase_freqs) < 7 && filt_order > 3
    ft_warning(['Think about using a lower filter order '...
        '(e.g. cfg.filt_order = 3)']);
end

% If incorrect method abort and warn  the user
if ~any(strcmp({'tort','plv','ozkurt','canolty'},method))
    error(['Specified PAC method ''' method ''' not supported']);
end

% Check whether PAC can be detected
switch amp_bandw_method
    
    case 'number'
        % If the bandwidth is less than the maximum phase frequency...
        if amp_bandw < max(phase_freqs)
            
            error(['You will not be able to detect PAC with this configuration.'...
                ' Reduce the phase to ' ...
                num2str(amp_bandw) 'Hz, or increase the amplitude bandwidth to '...
                num2str(max(phase_freqs)+1) 'Hz']);
        end
    case 'maxphase'
        % If minimum
        if min(amp_freqs) - max(phase_freqs)*1.5 < max(phase_freqs)
            error(['You will not be able to detect PAC with this configuration.'])
        end
    case 'centre_freq'
        % If
        if min(amp_freqs)/2.5 < max(phase_freqs)
            try
                low_amp = min(amp_freqs(find(amp_freqs/2.5 > max(phase_freqs))));
            catch
                low_amp = '?';
            end
            
            error(['You will not be able to detect PAC with this configuration.'...
                ' Reduce the phase to ' ...
                num2str(min(amp_freqs)/2.5) 'Hz, or increase the amplitude to '...
                num2str(low_amp) 'Hz']);
        end
end

%% Filter Phase Frequencies & take 'angle'
disp('Filtering Phase...');

if ~isempty(mask)
    phase_filtered = zeros(size(data,1),length(phase_freqs),length(data(:,mask(1):...
        mask(2))));
else
    phase_filtered = zeros(size(data,1),length(phase_freqs),length(data));
    
end

for phase = 1:length(phase_freqs)
    try
        [filt] = ft_preproc_bandpassfilter(data, Fs,...
            [phase_freqs(phase)-1 phase_freqs(phase)+1],...
            filt_order, 'but', 'twopass', 'no');
    catch
        error('Could not filter ... Perhaps try a lower filter order');
    end
    
    if ~isempty(mask)
        phase_filtered(:,phase,:) = ft_preproc_hilbert(filt(:,mask(1):...
            mask(2)), 'angle');
    else
        phase_filtered(:,phase,:) = ft_preproc_hilbert(filt, 'angle');
    end
    
    clear filt
end


%% Filter Amplitude & Take 'abs'
disp('Filtering Amplitude...');

if ~isempty(mask)
    amp_filtered = zeros(size(data,1),length(amp_freqs),length(data(:,mask(1):...
        mask(2))));
else
    amp_filtered = zeros(size(data,1),length(amp_freqs),length(data));
end

for amp = 1:length(amp_freqs)
    
    % Switch based on bandwidth method
    switch amp_bandw_method
        
        case 'number'
            
            if amp == 1
                fprintf('Bandwidth = %.1fHz\n',amp_bandw);
            end
            
            Af1 = amp_freqs(amp) - amp_bandw;
            Af2 = amp_freqs(amp) + amp_bandw;
            %
        case 'maxphase'
            if amp == 1
                fprintf('Bandwidth = %.1fHz\n',1.5.*max(phase_freqs));
            end
            %
            Af1 = amp_freqs(amp) - 1.5*max(phase_freqs);
            Af2 = amp_freqs(amp) + 1.5*max(phase_freqs);
            
        case 'centre_freq'
            if amp == 1
                fprintf('Bandwidth = 2.5* centre amplitude frequency\n')
            end
            
            Af1 = round(amp_freqs(amp) -(amp_freqs(amp)/2.5));
            Af2 = round(amp_freqs(amp) +(amp_freqs(amp)/2.5));
            
            
    end
    
    % Filter
    [filt] = ft_preproc_bandpassfilter(data, Fs,...
        [Af1 Af2],filt_order, 'but', 'twopass', 'no');
    
    % Take abs (and mask values if required)
    if ~isempty(mask)
        amp_filtered(:,amp,:) = ft_preproc_hilbert(filt(:,mask(1):...
            mask(2)), 'abs');
    else
        amp_filtered(:,amp,:) = ft_preproc_hilbert(filt, 'abs');
    end
    
    clear filt Af1 Af2
end

%% Compute Surrogates
if ~isempty(surr_method)
    % Switch based on the surrogate methods
    switch surr_method
        case 'swap_blocks'
            
            % Create matrix for amplitude
            surr_data_amp = [];
            
            % Create matrix for phase
            surr_data_phase = [];
            
            warning('Use with caution - NEEDS WORK');
            
            % Get random phase and amplitude trials for each surrogate
            rand_phase_trial = randi([1 size(data,1)], 1, surr_N.*1.5);
            rand_amp_trial = randi([1 size(data,1)], 1, surr_N.*1.5);
            
            % Remove instances where the same phase and amplitude trial has
            % been selected
            find_same_trials = find(rand_amp_trial-rand_phase_trial==0);
            rand_phase_trial(find_same_trials) = [];
            rand_amp_trial(find_same_trials) = [];
            
            % Now select the correct number of surrogates
            rand_phase_trial    = rand_phase_trial(1:surr_N);
            rand_amp_trial      = rand_amp_trial(1:surr_N);
            
            % Generate random inteegers of the ampitude timeseries 
            % to cut at
            point_to_cut = randi([1 size(amp_filtered,3)],1, surr_N);
            
            disp('Computing surrogate data...');
            for surr = 1:surr_N
                
                % Get amplitude data for this surrogate run
                amp_data_spare = amp_filtered(...
                    rand_amp_trial(surr),:,:);
                
                % Split this data at a random point
                x = amp_data_spare(:,:,point_to_cut(surr):end);
                y = amp_data_spare(:,:,1:point_to_cut(surr)-1);
                
                % Join back together but with end portion at the start
                amp_data_spare2 = cat(3,x,y);
                
                % Add amplitude data to array outside the loop
                surr_data_amp(surr,:,:) = amp_data_spare2;
                
                % Add phase data to array outside the loop
                surr_data_phase(surr,:,:) = phase_filtered(...
                    rand_phase_trial(surr),:,:);    
                
                clear amp_data_spare x y amp_data_spare2
            end
            
        case 'swap_trials'
            
            % Create matrix for amplitude
            surr_data_amp = [];
            
            % Create matrix of zeros for phase
            surr_data_phase = [];
            
            warning('Use with caution - NEEDS WORK');
            
            % Get random phase and amplitude trials for each surrogate
            
            % Set seed if specified
            if ~isempty(surr_seed)
                rng('default');
                rng(surr_seed(1));
            end
            
            rand_phase_trial = randi([1 size(data,1)], 1, surr_N.*1.5);
            
            % Set seed if specified
            if ~isempty(surr_seed)
                rng('default');
                rng(surr_seed(2));
            end
            
            rand_amp_trial = randi([1 size(data,1)], 1, surr_N.*1.5);
            
            % Remove instances where the same phase and amplitude trial has
            % been selected
            find_same_trials = find(rand_amp_trial-rand_phase_trial==0);
            rand_phase_trial(find_same_trials) = [];
            rand_amp_trial(find_same_trials) = [];
            
            % Now select the correct number of surrogates
            rand_phase_trial    = rand_phase_trial(1:surr_N);
            rand_amp_trial      = rand_amp_trial(1:surr_N);
            
            disp('Computing surrogate data...');
            for surr = 1:surr_N
                % Split data
                surr_data_amp(surr,:,:) = amp_filtered(...
                    rand_amp_trial(surr),:,:);
                
                surr_data_phase(surr,:,:) = phase_filtered(...
                    rand_phase_trial(surr),:,:);
            end
    end
    
end

%% PAC computation
MI_matrix_raw = zeros(size(data,1),length(amp_freqs),length(phase_freqs));

for trial = 1:size(data,1)
    for phase = 1:length(phase_freqs)
        for amp = 1:length(amp_freqs)
            
            phase_data = squeeze(phase_filtered(trial,phase,:));
            amp_data = squeeze(amp_filtered(trial,amp,:));
            
            % Switch based on the method of PAC computation
            switch method
                case 'tort'
                    [MI] = calc_MI_tort(phase_data,amp_data,18);
                    
                case 'ozkurt'
                    [MI] = calc_MI_ozkurt(phase_data,amp_data);
                    
                case 'plv'
                    [MI] = cohen_PLV(phase_data,amp_data);
                    
                case 'canolty'
                    [MI] = calc_MI_canolty(phase_data,amp_data);
            end
            
            % Add to matrix outside the loop
            MI_matrix_raw(trial,amp,phase) = MI;
        end
    end
end

%% Average PAC over trials if specified

if strcmp(avg_PAC,'yes')
    MI_matrix_raw = squeeze(mean(MI_matrix_raw,1));
    
elseif strcmp(avg_PAC,'no');
    disp('Returning PAC values per trial');
else
    ft_warning('Please specify cfg.avg_PAC = ''yes'' or ''no''');
end

%% Perform surrogate PAC Analysis
if ~isempty(surr_method)
    
    % Matrix to hold surrogates
    MI_matrix_surr = zeros(surr_N,length(amp_freqs),length(phase_freqs));
    
    % Length of amplitudes
    len_of_amp = size(amp_filtered,3);

    % Start surrogate loop
    ft_progress('init', 'text',    'Please wait...')
    for surr = 1:surr_N
        ft_progress(surr/surr_N, 'Surrogate %d of %d', surr, surr_N)  % show string, x=i/N
        
        for phase = 1:length(phase_freqs)
            for amp = 1:length(amp_freqs)
                
                % Get surrogate amp & phase
                data_phase = squeeze(surr_data_phase(surr,phase,:));
                data_amp = squeeze(surr_data_amp(surr,amp,:));
                
                % Switch based on the method of PAC computation
                switch method
                    case 'tort'
                        [MI] = calc_MI_tort(data_phase,data_amp,18);
                        
                    case 'ozkurt'
                        [MI] = calc_MI_ozkurt(data_phase,data_amp);
                        
                    case 'plv'
                        [MI] = cohen_PLV(data_phase,data_amp);
                        
                    case 'canolty'
                        [MI] = calc_MI_canolty(data_phase,data_amp);
                end
                
                % Add to matrix outside the loop
                MI_matrix_surr(surr,amp,phase) = MI;
            end
        end
    end
ft_progress('close')
    
    
end

