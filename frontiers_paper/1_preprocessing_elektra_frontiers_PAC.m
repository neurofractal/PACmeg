%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 1_preprocessing_elekta_frontiers_PAC.m
%
% Matlab script to perform SIMPLE preprocessing using the Fieldtrip
% toolbox (common preprocessing, visualisation and artefact rejection
% steps).
%
% Here we use visual grating data, obtained from the Aston Brain Centre,
% Birmingham (UK), using a Neuromag Elekta (Triux 306 channel) MEG scanner.
% N.B. The trigger code for the onset of the visual grating is 'STI005'. 
%
% Output = data_clean_noICA
%
% Written by Robert Seymour - May 2017
%
% Please note that these scripts have been optimised for the Windows
% operating system and MATLAB versions about 2014b.
%
% Runnng time: 15 minutes (requires user to manually inspect trial
% variances and enter the bad trial numbers - see bad_trial_indices.tsv)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath;
sensory_PAC;
addpath(fieldtrip_dir);
addpath(genpath(scripts_dir));
ft_defaults

% If you do not run these lines you will have to manually specify:
% - subject = subject list
% - data_dir = directory which contains the MEG & anatomical information
% - scripts_dir = directory with ALL the scripts
% - fieldtrip_dir = directory containing the Fieldtrip toolbox

for i = 1:length(subject)
    %% Prerequisites
    % Make a new directory in the scripts folder & cd there
    mkdir([scripts_dir '\' subject{i}]);
    cd([scripts_dir '\' subject{i}]);
    
    % Specify location of the datafile
    rawfile = [data_dir '\' subject{i} '\meg\' subject{i} '_visualgrating-task_quat_tsss.fif'];
    % Creates log file
    diary(sprintf('log %s.out',subject{i}));
    c = datestr(clock); %time and date
    disp(sprintf('Running preprocessing script for subject{i} %s',subject{i}))
    disp(c)
    
    %% Epoching & Filtering
    % Epoch the whole dataset into one continous dataset and apply
    % the appropriate filters
    cfg = [];
    cfg.trialfun = 'ft_trialfun_general';
    cfg.headerfile = rawfile;
    cfg.datafile = rawfile;
    cfg.channel = 'MEG';
    cfg.trialdef.triallength = Inf;
    cfg.trialdef.ntrials = 1;
    cfg = ft_definetrial(cfg);
    
    cfg.continuous = 'yes';
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [0.5 250];
    cfg.channel = 'MEG';
    cfg.dftfilter = 'yes';
    cfg.dftfreq = [50];
    alldata = ft_preprocessing(cfg);
    
    % Deal with 50Hz line noise using a bandstop filter
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49.5 50.5];
    alldata = ft_preprocessing(cfg,alldata);
    
    % Deal with 100Hz line noise using a bandstop filter
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [99.5 100.5];
    alldata = ft_preprocessing(cfg,alldata);
    
    % Epoch your filtered data based on a specific trigger
    cfg = [];
    cfg.trialfun = 'ft_trialfun_general';
    cfg.headerfile = rawfile;
    cfg.datafile = rawfile;
    cfg.channel = 'MEG';
    cfg.trialdef.eventtype = 'STI005';
    disp('Trigger Value is STI005');
    cfg.trialdef.prestim = 2.0;         % pre-stimulus interval
    cfg.trialdef.poststim = 2.0;        % post-stimulus interval
    cfg = ft_definetrial(cfg);
    
    data = ft_redefinetrial(cfg,alldata); %redefines the filtered data
    
    % Detrend and demean each trial
    cfg = [];
    cfg.demean = 'yes';
    cfg.detrend = 'yes';
    data = ft_preprocessing(cfg,data);
    
    %% Reject Trials
    % Display visual trial summary to reject deviant trials.
    % You need to load the mag + grad separately due to different scales.
    % Please refer to the .tsv file for indices of rejected trials.
    
    cfg = [];
    cfg.method = 'summary';
    cfg.keepchannel = 'yes';
    cfg.channel = 'MEGMAG';
    clean1 = ft_rejectvisual(cfg, data);
    % Now load this
    cfg.channel = 'MEGGRAD';
    clean2 = ft_rejectvisual(cfg, clean1);
    data = clean2; clear clean1 clean2
    close all
    
    %% Save the clean data
    data_clean_noICA = data;
    save data_clean_noICA data_clean_noICA
    clear data_clean_noICA
    close all
    
    %% Go back to scripts directory
    cd(scripts_dir);
end