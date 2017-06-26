%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 1_preprocessing_elekta_frontiers_PAC.m
%
% This is a Matlab script to perform SIMPLE preprocessing on the visual
% grating data, obtained from the Aston Brain Centre, Birmingham, UK.
%
% The script runs through the common preprocessing, visualisation
% and artefact rejection steps.
%
% Output = data_clean_noICA
%
% Written by Robert Seymour - May 2017
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath;
PAC_frontiers_dir;
addpath(fieldtrip_dir);
ft_defaults

%% Specify Subject List
 subject = sort({'MP','GR','DS','EC','VS','LA','AE','SY','GW',...
     'SW','DK','LH','KM','FL','AN'});

for i = 1:length(subject)
    %% Prerequisites
    % Make a new directory in the scripts folder & cd there
    
    mkdir([scripts_dir '\' subject{i}]);
    cd([scripts_dir '\' subject{i}]);
    
    % Specify location of the datafile
    rawfile = [data_dir '\' 'rs_asd_' lower(subject{i}) '_aliens_quat_tsss.fif'];
    % Creates log file
    diary(sprintf('log %s.out',subject{i}));
    c = datestr(clock); %time and date
    disp(sprintf('Running preprocessing script for subject{i} %s',subject{i}))
    disp(c)
    %% Epoching & Filtering
    % Epoch the whole dataset into one continous dataset and apply
    % the appropriate filters
    cfg = [];
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
    
    % Deal with 50Hz line noise
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [49.5 50.5];
    alldata = ft_preprocessing(cfg,alldata);
    
    % Deal with 100Hz line noise
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [99.5 100.5];
    alldata = ft_preprocessing(cfg,alldata);
    
    % Epoch your filtered data based on a specific trigger
    cfg = [];
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
    % You need to load the mag + grad separately due to different scales
    
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