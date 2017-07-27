%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 2_get_source_power.m
%
% This script computes source-space power for baseline and grating periods
% in the gamma-band (40-60Hz) and then the alpha-band (8-13Hz), using an
% LCMV beamformer.
%
% For source localisation, a 3D cortical mesh of 4002 vertices per 
% hemisphere is used, created using Freesurfer and HCP scripts. 
%
% A grandaverage is computed for each frequency band and exported to .nii
% and .gii formats. Please use your favorite MRI visualisation software to
% view these whole-brain % power change maps. Examples include: BrainNet
% Viewer (https://www.nitrc.org/projects/bnv/); MRIcron 
% (http://people.cas.sc.edu/rorden/mricron/index.html) and Connectome
% Workbench (http://www.humanconnectome.org/software/connectome-workbench).
%
% Written by Robert Seymour June 2017
%
% Please note that these scripts have been optimised for the Windows
% operating system and MATLAB versions about 2014b.
%
% Running Time: 15-20 mins per frequency band
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath
sensory_PAC;
addpath(fieldtrip_dir);
addpath(genpath(scripts_dir));
ft_defaults

% If you do not run these lines you will have to manually specify:
% - subject = subject list
% - data_dir = directory which contains the MEG & anatomical information
% - scripts_dir = directory with ALL the scripts
% - fieldtrip_dir = directory containing the Fieldtrip toolbox

%% Arrays to hold source estimates for each subject
sourcepre_all = []; %baseline
sourcepost_all = []; %grating period

%% Pre-load the Conte69 Brain Template from the HCP
conte69brain = ft_read_headshape({[scripts_dir ...
     '\Q1-Q6_R440.L.midthickness.4k_fs_LR.surf.gii'],...
    [scripts_dir  '\Q1-Q6_R440.R.midthickness.4k_fs_LR.surf.gii']});

%% Start Loop
for i=1:length(subject)
   
    %% Load variables required for source analysis
    load([scripts_dir '\' subject{i} '\data_clean_noICA.mat']); % non-ICA'd data
    load([data_dir '\' subject{i} '\anat\sens.mat']);
    load([data_dir '\' subject{i} '\anat\seg.mat']);
    % Convert to consistent units
    sens = ft_convert_units(sens,'m');
    seg = ft_convert_units(seg,'m');
    %% Set the current directory
    cd([scripts_dir '\' subject{i}])
    
    %% Set bad channel list - can change to specific channels if necessary
    chans_included = {'MEG', '-MEG0322', '-MEG2542','-MEG0111','-MEG0532'};
    cfg = [];
    cfg.channel = chans_included;
    data_clean_noICA = ft_preprocessing(cfg,data_clean_noICA);
    
    %% Load 3D 4k Cortical Mesh for L/R hemisphere & Concatenate
    sourcespace = ft_read_headshape({[data_dir '\' subject{i} '\anat\'...
        subject{i} '.L.midthickness.4k_fs_LR.surf.gii'],[data_dir...
        '\' subject{i} '\anat\' subject{i} '.R.midthickness.4k_fs_LR.surf.gii']});
    sourcespace = ft_convert_units(sourcespace,'m');
    
    %% Make sure rank of the data is below 64
    
    % determine numcomponent by doing an eig on the covariance matrix
    covar = zeros(numel(data_clean_noICA.label));
    for itrial = 1:numel(data_clean_noICA.trial)
        currtrial = data_clean_noICA.trial{itrial};
        covar = covar + currtrial*currtrial.';
    end
    [V, D] = eig(covar);
    D = sort(diag(D),'descend');
    D = D ./ sum(D);
    Dcum = cumsum(D);
    % number of components accounting for 99% of variance in covar matrix
    numcomponent = find(Dcum>.99,1,'first'); 
    
    % Make sure the rank is below 64
    if numcomponent > 65
        numcomponent = 64;
    end
    
    disp(sprintf('\n Reducing the data to %d components \n',numcomponent));
    
    cfg = [];
    cfg.method = 'pca';
    cfg.updatesens = 'yes';
    cfg.channel = chans_included;
    comp = ft_componentanalysis(cfg, data_clean_noICA);
    
    cfg = [];
    cfg.updatesens = 'yes';
    cfg.component = comp.label(numcomponent:end);
    data_clean_noICA = ft_rejectcomponent(cfg, comp);
    
    %% Bandpass Filter 
    cfg = [];
    cfg.channel = chans_included; 
    cfg.bpfilter = 'yes';
    cfg.bpfreq = [40 60];    %band-pass filter in the required range
    data_filtered = ft_preprocessing(cfg,data_clean_noICA)
    
    %% Here we redefine trials based on the time-points of interest.
    % Make sure the timepoints are of equivalent length
    cfg = [];
    cfg.toilim = [-1.5 -0.3];
    datapre = ft_redefinetrial(cfg, data_filtered);
    cfg.toilim = [0.3 1.5];
    datapost = ft_redefinetrial(cfg, data_filtered);
    
    % Here we are keeping all parts of the trial for your covariance matrix
    cfg = [];
    cfg.covariance = 'yes';
    cfg.covariancewindow = [-1.5 1.5]
    avg = ft_timelockanalysis(cfg,data_filtered);
    
    % Time lock analysis for datapre and datapost period
    cfg = [];
    cfg.covariance='yes';
    cfg.covariancewindow = [-1.5 1.5];
    avgpre = ft_timelockanalysis(cfg,datapre);
    avgpst = ft_timelockanalysis(cfg,datapost);

    %% Setup pre-requisites for source localisation
    % Create headmodel
    cfg        = [];
    cfg.method = 'singleshell';
    headmodel  = ft_prepare_headmodel(cfg, seg);
    
    % Load headshape
    headshape = ft_read_headshape([data_dir '\' subject{i} '\meg\' subject{i} '_visualgrating-task_quat_tsss.fif']);
    headshape = ft_convert_units(headshape,'m');
    
    %% Create leadfields
    cfg=[];
    cfg.headmodel=headmodel;
    cfg.channel= chans_included;
    cfg.grid.pos= sourcespace.pos;
    cfg.grid.unit      ='m';
    cfg.grad=sens;
    cfg.grid.inside = [1:1:length(cfg.grid.pos)]; %always inside - check manually
    cfg.normalize = 'yes';
    sourcemodel_virt=ft_prepare_leadfield(cfg);
    
    % Create Figure to Show Forward Solution
    figure; hold on;
    ft_plot_headshape(headshape)
    ft_plot_mesh(sourcespace,'facecolor','w','edgecolor',[0.5, 0.5, 0.5],'facealpha',0.1);
    dataV1 = ft_plot_mesh(sourcemodel_virt.pos(1:8004,:),'vertexcolor','k');
    ft_plot_sens(sens, 'style', 'black*')
    set(gcf,'color','w'); drawnow;
    
    %% Perform source analysis across the mesh
    cfg=[];
    cfg.keeptrials = 'no';
    cfg.channel= chans_included;
    cfg.grad = sens;
    cfg.senstype = 'MEG';
    cfg.method='lcmv';
    cfg.grid = sourcemodel_virt;
    cfg.grid.unit      ='m';
    cfg.headmodel=headmodel;
    cfg.lcmv.lamda='5%';
    cfg.lcmv.fixedori = 'yes';
    cfg.lcmv.keepfilter = 'yes';
    cfg.lcmv.projectmom = 'no';
    cfg.lcmv.normalize = 'yes';
    sourceavg=ft_sourceanalysis(cfg, avg);
    
    % use common filter for subsequent source analysis
    cfg.grid.filter=sourceavg.avg.filter; %uses the grid from the whole trial average
    %Pre-grating
    sourcepreS1 = ft_sourceanalysis(cfg, avgpre); 
    sourcepreS1.pos = conte69brain.pos; % make sure positions are consistent
    sourcepre_all{i} = sourcepreS1; 
    %Post-grating
    sourcepstS1=ft_sourceanalysis(cfg, avgpst); 
    sourcepstS1.pos = conte69brain.pos; % make sure positions are consistent
    sourcepost_all{i} = sourcepstS1;
end

%% Compute Source Grand Average in the Gamma Band
cfg =[];
sourcepost_avg = ft_sourcegrandaverage(cfg,sourcepost_all{:});
sourcepre_avg = ft_sourcegrandaverage(cfg,sourcepre_all{:});

%% Compute Percentage Power Change From Baseline
cfg = [];
cfg.parameter = 'pow';
cfg.operation = '((x1-x2)/x2)*100'; % calculate & change
diff = ft_math(cfg,sourcepost_avg,sourcepre_avg);

%% Plot on the Conte69 Brain (doesn't look very good)
figure;ft_plot_mesh(conte69brain, 'vertexcolor', -diff.pow);colormap(hot);colorbar;

%% Interpolate onto MNI template
mri = ft_read_mri([fieldtrip_dir '\template\anatomy\single_subj_T1.nii']);

cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
diffint  = ft_sourceinterpolate(cfg, diff, mri); 

%% Export to nifti formt and use your favourite MRI software to visualise
cd(scripts_dir);

cfg = [];
cfg.filetype = 'nifti';
cfg.filename = 'group_visual_gamma_grandavg';
cfg.parameter = 'pow';
ft_sourcewrite(cfg,diffint);

% This corresponds to Figure 3A

%% Export to connectome workbench (specfic to my computer)

%system('D:\Software\workbench\bin_windows64\wb_command -volume-to-surface-mapping D:\scripts\PAC_for_frontiers\group_visual_gamma_grandavg.nii D:\Software\workbench\bin_windows64\Conte69_atlas-v2.LR.32k_fs_LR.wb\32k_ConteAtlas_v2\Conte69.L.midthickness.32k_fs_LR.surf.gii D:\scripts\PAC_for_frontiers\group_visual_gamma_grandavg.nii_LEFT.shape.gii -trilinear')
%system('D:\Software\workbench\bin_windows64\wb_command -volume-to-surface-mapping D:\scripts\PAC_for_frontiers\group_visual_gamma_grandavg.nii D:\Software\workbench\bin_windows64\Conte69_atlas-v2.LR.32k_fs_LR.wb\32k_ConteAtlas_v2\Conte69.R.midthickness.32k_fs_LR.surf.gii D:\scripts\PAC_for_frontiers\group_visual_gamma_grandavg.nii_RIGHT.shape.gii -trilinear')
















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Now onto the alpha-band (8-13Hz)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd(scripts_dir)
clear all ; close all 
clc

%% Load computer-specific information
sensory_PAC;
addpath(fieldtrip_dir);
ft_defaults

%% Arrays to hold source estimates for each subject
sourcepre_all = []; %baseline
sourcepost_all = []; %grating

%% Pre-load the Conte69 Brain Template from the HCP
conte69brain = ft_read_headshape({[scripts_dir ...
     '\Q1-Q6_R440.L.midthickness.4k_fs_LR.surf.gii'],...
    [scripts_dir  '\Q1-Q6_R440.R.midthickness.4k_fs_LR.surf.gii']});

%% Start Loop
for i=1:length(subject)
   
    %% Load variables required for source analysis
    load([scripts_dir '\' subject{i} '\data_clean_noICA.mat']); % non-ICA'd data
    load([data_dir '\' subject{i} '\anat\sens.mat']);
    load([data_dir '\' subject{i} '\anat\seg.mat']);
    % Convert to consistent units
    sens = ft_convert_units(sens,'m');
    seg = ft_convert_units(seg,'m');
    %% Set the current directory
    cd([scripts_dir '\' subject{i}])
    
    %% Set bad channel list - can change to specific channels if necessary
    chans_included = {'MEG', '-MEG0322', '-MEG2542','-MEG0111','-MEG0532'};
    cfg = [];
    cfg.channel = chans_included;
    data_clean_noICA = ft_preprocessing(cfg,data_clean_noICA);
    
    %% Load 3D 4k Cortical Mesh for L/R hemisphere & Concatenate
    sourcespace = ft_read_headshape({[data_dir '\' subject{i} '\anat\'...
        subject{i} '.L.midthickness.4k_fs_LR.surf.gii'],[data_dir...
        '\' subject{i} '\anat\' subject{i} '.R.midthickness.4k_fs_LR.surf.gii']});
    sourcespace = ft_convert_units(sourcespace,'m');
    
    %% Do your timelock analysis on the data & compute covariance
    
    % determine numcomponent by doing an eig on the covariance matrix
    covar = zeros(numel(data_clean_noICA.label));
    for itrial = 1:numel(data_clean_noICA.trial)
        currtrial = data_clean_noICA.trial{itrial};
        covar = covar + currtrial*currtrial.';
    end
    [V, D] = eig(covar);
    D = sort(diag(D),'descend');
    D = D ./ sum(D);
    Dcum = cumsum(D);
    numcomponent = find(Dcum>.99,1,'first'); % number of components accounting for 99% of variance in covar matrix
    
    % Make sure the rank is below 64
    if numcomponent > 65
        numcomponent = 64;
    end
    
    disp(sprintf('\n Reducing the data to %d components \n',numcomponent));
    
    cfg = [];
    cfg.method = 'pca';
    cfg.updatesens = 'yes';
    cfg.channel = chans_included;
    comp = ft_componentanalysis(cfg, data_clean_noICA);
    
    cfg = [];
    cfg.updatesens = 'yes';
    cfg.component = comp.label(numcomponent:end);
    data_clean_noICA = ft_rejectcomponent(cfg, comp);
    
    %% BP Filter & Select Gradiometers
    cfg = [];
    cfg.channel = chans_included; 
    cfg.bpfilter = 'yes'
    cfg.bpfreq = [8 13];    %band-pass filter in the required range
    data_filtered = ft_preprocessing(cfg,data_clean_noICA)
    
    %% Here we redefine trials based on the time-points of interest.
    % Make sure the timepoints are of equivalent length
    cfg = [];
    cfg.toilim = [-1.5 -0.3];
    datapre = ft_redefinetrial(cfg, data_filtered);
    cfg.toilim = [0.3 1.5];
    datapost = ft_redefinetrial(cfg, data_filtered);
    
    % Here we are keeping all parts of the trial for your covariance matrix
    cfg = [];
    cfg.covariance = 'yes';
    cfg.covariancewindow = [-1.5 1.5]
    avg = ft_timelockanalysis(cfg,data_filtered);
    
    % Time lock analysis for datapre and datapost period
    cfg = [];
    cfg.covariance='yes';
    cfg.covariancewindow = [-1.5 1.5]
    avgpre = ft_timelockanalysis(cfg,datapre);
    avgpst = ft_timelockanalysis(cfg,datapost);

    %% Setup pre-requisites for source localisation
    % Create headmodel
    cfg        = [];
    cfg.method = 'singleshell';
    headmodel  = ft_prepare_headmodel(cfg, seg);
    
        % Load headshape
    headshape = ft_read_headshape([data_dir '\' subject{i} '\meg\' subject{i} '_visualgrating-task_quat_tsss.fif']);
    headshape = ft_convert_units(headshape,'m');
    
    %% Create leadfields
    cfg=[];
    cfg.headmodel=headmodel;
    cfg.channel= chans_included;
    cfg.grid.pos= sourcespace.pos;
    cfg.grid.unit      ='m';
    cfg.grad=sens;
    cfg.grid.inside = [1:1:length(cfg.grid.pos)]; %always inside - check manually
    cfg.normalize = 'yes';
    sourcemodel_virt=ft_prepare_leadfield(cfg);
    
    % Create Figure to Show Forward Solution
    figure; hold on;
    ft_plot_headshape(headshape)
    ft_plot_mesh(sourcespace,'facecolor','w','edgecolor',[0.5, 0.5, 0.5],'facealpha',0.1);
    dataV1 = ft_plot_mesh(sourcemodel_virt.pos(1:8004,:),'vertexcolor','k');
    ft_plot_sens(sens, 'style', 'black*')
    set(gcf,'color','w'); drawnow;
    
    %% Perform source analysis across the mesh
    cfg=[];
    cfg.keeptrials = 'no';
    cfg.channel= chans_included;
    cfg.grad = sens;
    cfg.senstype = 'MEG';
    cfg.method='lcmv';
    cfg.grid = sourcemodel_virt;
    cfg.grid.unit      ='m';
    cfg.headmodel=headmodel;
    cfg.lcmv.lamda='5%';
    cfg.lcmv.fixedori = 'yes';
    cfg.lcmv.keepfilter = 'yes';
    cfg.lcmv.projectmom = 'no';
    cfg.lcmv.normalize = 'yes';
    sourceavg=ft_sourceanalysis(cfg, avg);
    
    % use common filter for subsequent source analysis
    cfg.grid.filter=sourceavg.avg.filter; %uses the grid from the whole trial average
    %Pre-grating
    sourcepreS1 = ft_sourceanalysis(cfg, avgpre); 
    sourcepreS1.pos = conte69brain.pos; % make sure positions are consistent
    sourcepre_all{i} = sourcepreS1; 
    %Post-grating
    sourcepstS1=ft_sourceanalysis(cfg, avgpst); 
    sourcepstS1.pos = conte69brain.pos; % make sure positions are consistent
    sourcepost_all{i} = sourcepstS1;
end

%% Compute Source Grand Average
cfg =[];
sourcepost_avg = ft_sourcegrandaverage(cfg,sourcepost_all{:});
sourcepre_avg = ft_sourcegrandaverage(cfg,sourcepre_all{:});

%% Take Post-Grating Power from Baseline Power
cfg = [];
cfg.parameter = 'pow';
cfg.operation = '((x1-x2)/x2)*100';
diff = ft_math(cfg,sourcepost_avg,sourcepre_avg);

%% Plot on the Conte69 Brain (deosn't look very good)
figure;ft_plot_mesh(conte69brain, 'vertexcolor', -diff.pow);colormap(hot);colorbar;

%% Interpolate onto MNI template
mri = ft_read_mri([fieldtrip_dir '\template\anatomy\single_subj_T1.nii']);

cfg              = [];
cfg.voxelcoord   = 'no';
cfg.parameter    = 'pow';
cfg.interpmethod = 'nearest';
diffint  = ft_sourceinterpolate(cfg, diff, mri); 

%% Export to nifti formt and use your favourite MRI software to visualise
cd(scripts_dir);

cfg = [];
cfg.filetype = 'nifti';
cfg.filename = 'group_visual_alpha_grandavg';
cfg.parameter = 'pow';
ft_sourcewrite(cfg,diffint);

% This corresponds to Figure 3B

%% Export to connectome workbench (specfic to my computer)

%system('D:\Software\workbench\bin_windows64\wb_command -volume-to-surface-mapping D:\scripts\PAC_for_frontiers\group_visual_alpha_grandavg.nii D:\Software\workbench\bin_windows64\Conte69_atlas-v2.LR.32k_fs_LR.wb\32k_ConteAtlas_v2\Conte69.L.midthickness.32k_fs_LR.surf.gii D:\scripts\PAC_for_frontiers\group_visual_alpha_grandavg.nii_LEFT.shape.gii -trilinear')
%system('D:\Software\workbench\bin_windows64\wb_command -volume-to-surface-mapping D:\scripts\PAC_for_frontiers\group_visual_alpha_grandavg.nii D:\Software\workbench\bin_windows64\Conte69_atlas-v2.LR.32k_fs_LR.wb\32k_ConteAtlas_v2\Conte69.R.midthickness.32k_fs_LR.surf.gii D:\scripts\PAC_for_frontiers\group_visual_alpha_grandavg.nii_RIGHT.shape.gii -trilinear')


