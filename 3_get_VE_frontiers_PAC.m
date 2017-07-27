%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script computes a virtual electrode time-series from area V1. Source
% analysis is performed across all vertices of the 3D cortical mesh. 
% Vertex locations within visual area V1 are then defined using the 
% HCP-MMP 1.0 atlas.
%
% The spatial filters from these vertices are concatenated, multiplied by
% the sensor-level covariance mstrix and a PCA is performed to extract a
% single V1 filter. This is multipled by the sensor-level trial data to
% generate VE_V1.mat. 
%
% Please note: It is also perfectly viable to use a volumetric atlas (e.g.
% AAL) to generate this V1 virtual electrode.
%
% Output: VE_V1.mat. This is saved in the sensory_PAC/sub-XX/ directory
%
% Written by Robert Seymour - June 2017
%
% Please note that these scripts have been optimised for the Windows
% operating system and MATLAB versions about 2014b.
%
% Running-time: 15-20 minutes
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

 %% Preload the HCP atlas
 % Here we are using the 4k HCP atlas mesh to define visual ROIs
 % from the subject-specific 4k cortical mesh
 load([scripts_dir '\' 'atlas_MSMAll_4k.mat']);
 atlas = ft_convert_units(atlas,'m');

%% Start Loop
for i=1:length(subject)
   
    %% Load variables required for source analysis
    load([scripts_dir '\' subject{i} '\data_clean_noICA.mat']);
    load([data_dir '\' subject{i} '\anat\sens.mat']);
    load([data_dir '\' subject{i} '\anat\seg.mat']);
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
    
    %% Time-Lock Analysis
    cfg = [];
    cfg.channel = chans_included;
    cfg.covariance = 'yes'; % compute the covariance for single trials, then average
    cfg.covariancewindow = [-1.5 1.5]; % compute the covariance for single trials, then average
    cfg.preproc.baselinewindow = [-inf 0];  % reapply the baseline correction
    cfg.keeptrials = 'no';
    timelock1 = ft_timelockanalysis(cfg, data_clean_noICA);
    
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
    source=ft_sourceanalysis(cfg, timelock1);

    %% Compute the V1 virtual electrode
    
    % Get spatial filters from 182 V1 vertices (left and right hemisphere) 
    indx_V1_L = find(ismember(atlas.parcellationlabel,'L_V1_ROI')); % find index of the required label
    sel = find(atlas.parcellation==indx_V1_L);
    vertices_V1_L    = cat(1,source.avg.filter{sel});
    vertices_V1_L    = vertices_V1_L(12:end,:);
    
    indx_V1_R = find(ismember(atlas.parcellationlabel,'R_V1_ROI')); % find index of the required label
    sel = find(atlas.parcellation==indx_V1_R);
    vertices_V1_R    = cat(1,source.avg.filter{sel});
    vertices_V1_R    = vertices_V1_R(12:end,:);
    
    % Perform PCA on concatenated filters * sensor-level covar matrix
    F = vertcat(vertices_V1_L,vertices_V1_R);
    [u,s,v] = svd(F*timelock1.cov*F');
    filter = u'*F;
    
    % Create VE using this filter
    VE_V1 = [];
    VE_V1.label = {'VE_V1'};
    VE_V1.trialinfo = data_clean_noICA.trialinfo;
    for sub=1:(length(data_clean_noICA.trialinfo))
        % note that this is the non-filtered "raw" data
        VE_V1.time{sub}       = data_clean_noICA.time{sub};
        VE_V1.trial{sub}(1,:) = filter(1,:)*data_clean_noICA.trial{sub}(:,:);
    end
    
    % Preserve .sampleinfo field to avoid warnings later
    VE_V1.sampleinfo = data_clean_noICA.sampleinfo;
    
    % Save
    save VE_V1 VE_V1
    
    %% Create TFR of the VE
    % Note - these results are not shown in the manuscript 
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.pad = 'nextpow2'
    cfg.foi = 20:1:100;
    cfg.toi = -2.0:0.02:2.0;
    cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.5;
    cfg.tapsmofrq  = ones(length(cfg.foi),1).*8;
    
    multitaper = ft_freqanalysis(cfg, VE_V1);
    
    %% Plot
    cfg                 = [];
    cfg.ylim            = [40 100];
    cfg.baseline        = [-1.5 0];
    cfg.xlim            = [-0.5 1.5];
    figure; ft_singleplotTFR(cfg, multitaper);
    title(sprintf('%s',subject{i}));
    colormap(jet)
end
    
            