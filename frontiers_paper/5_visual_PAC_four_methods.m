%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 5_visual_PAC_four_methods.m
%
% Script to compute PAC comodulograms for the pre and post grating period,
% using visual area V1 data. Four PAC algorithms are currently implemented:
% KL-MI-Tort, MVL-MI-Canolty, MVL-MI-Ozkurt and PLV-MI-Cohen.
%
% Each approach calculates PAC for 64 trials * 16 participants * 7 phase
% frequencies and 34 amplitude frequencies. This  will take some time. If
% performance is slow the user might wish to run the algorithms in parallel
% using 4 separate MATLAB windows.
%
% Once completed, the PAC comodulograms are statistically compared
% and the results are plotted. It is worth doing this part separately for
% each algorithm.
%
% Written by Robert Seymour - June 2017
%
% Please note that these scripts have been optimised for the Windows
% operating system and MATLAB versions about 2014b.
%
% Computation time: 4-6 hours
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

%% Start loop for all subjects
for sub = 1:length(subject)
    
    % Load in data and cd to the right place
    cd([scripts_dir '\' subject{sub}])
    load([scripts_dir '\' subject{sub} '\VE_V1.mat']);
    load([scripts_dir '\' subject{sub} '\data_clean_noICA.mat']);
    VE_V1.sampleinfo = data_clean_noICA.sampleinfo;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tort et al., (2010)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post,matrix_post_surrogates] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes','tort');
    save matrix_post_tort matrix_post;
    save matrix_post_tort_surrogates matrix_post_surrogates;
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre,matrix_pre_surrogates] = calc_MI(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes','tort')
    save matrix_pre_tort matrix_pre;
    save matrix_pre_tort_surrogates matrix_pre_surrogates;
    
    clear matrix_post matrix_pre matrix_post_surrogates matrix_pre_surrogates
    
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ozkurt et al., (2010)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post,matrix_post_surrogates] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes','ozkurt');
    save matrix_post_ozkurt matrix_post;
    save matrix_post_ozkurt_surrogates matrix_post_surrogates;
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre,matrix_pre_surrogates] = calc_MI(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes','ozkurt')
    save matrix_pre_ozkurt matrix_pre;
    save matrix_pre_ozkurt_surrogates matrix_pre_surrogates;
    
    clear matrix_post matrix_pre matrix_post_surrogates matrix_pre_surrogates
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Canolty et al., (2006)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post,matrix_post_surrogates] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes','canolty');
    save matrix_post_canolty matrix_post;
    save matrix_post_canolty_surrogates matrix_post_surrogates;
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre,matrix_pre_surrogates] = calc_MI(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes','canolty')
    save matrix_pre_canolty matrix_pre;
    save matrix_pre_canolty_surrogates matrix_pre_surrogates;
    
    clear matrix_post matrix_pre matrix_post_surrogates matrix_pre_surrogates
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLV
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post,matrix_post_surrogates] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes','PLV');
    save matrix_post_PLV matrix_post;
    save matrix_post_PLV_surrogates matrix_post_surrogates;
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre,matrix_pre_surrogates] = calc_MI(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes','PLV')
    save matrix_pre_PLV matrix_pre;
    save matrix_pre_PLV_surrogates matrix_pre_surrogates;
    
    clear matrix_post matrix_pre matrix_post_surrogates matrix_pre_surrogates
    
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Statistical Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Canolty et al., (2006) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_canolty] = get_PAC_stats('matrix_post_canolty.mat',...
    'matrix_pre_canolty',[7 13],[34 100],subject,scripts_dir,0)

[stat_canolty_surr] = get_PAC_stats('matrix_post_canolty_surrogates.mat',...
    'matrix_pre_canolty_surrogates',[7 13],[34 100],subject,scripts_dir,1)

make_smoothed_comodulograms(stat_canolty, [7 13], [34 100]);
title('Canolty 2006 - no surr');
make_smoothed_comodulograms(stat_canolty_surr, [7 13], [34 100]);
title('Canolty 2006 - with surr');

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ozkurt et al., (2011) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_ozkurt] = get_PAC_stats('matrix_post_ozkurt.mat',...
    'matrix_pre_ozkurt',[7 13],[34 100],subject,scripts_dir,0)

[stat_ozkurt_surr] = get_PAC_stats('matrix_post_ozkurt_surrogates.mat',...
    'matrix_pre_ozkurt_surrogates',[7 13],[34 100],subject,scripts_dir,1)


make_smoothed_comodulograms(stat_ozkurt, [7 13], [34 100]);
title('Okzurt 2011 - no surr');
make_smoothed_comodulograms(stat_ozkurt_surr, [7 13], [34 100]);
title('Okzurt 2011 - with surr');

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cohen et al., (2008) - PLV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_PLV] = get_PAC_stats('matrix_post_PLV.mat',...
    'matrix_pre_PLV',[7 13],[34 100],subject,scripts_dir,0)

[stat_PLV_surr] = get_PAC_stats('matrix_post_PLV_surrogates.mat',...
    'matrix_pre_PLV_surrogates',[7 13],[34 100],subject,scripts_dir,1)

make_smoothed_comodulograms(stat_PLV, [7 13], [34 100]);
title('Cohen PLV - no surr');
make_smoothed_comodulograms(stat_PLV_surr, [7 13], [34 100]);
title('Cohen PLV - with surr');

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tort et al., (2010) - MI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_tort] = get_PAC_stats('matrix_post_tort.mat',...
    'matrix_pre_tort.mat',[7 13],[34 100],subject,scripts_dir,0)

[stat_tort_surr] = get_PAC_stats('matrix_post_tort_surrogates.mat',...
    'matrix_pre_tort_surrogates.mat',[7 13],[34 100],subject,scripts_dir,1)

make_smoothed_comodulograms(stat_tort, [7 13], [34 100]);
title('Tort 2010 - no surr');
make_smoothed_comodulograms(stat_tort_surr, [7 13], [34 100]);
title('Tort 2010 - with surr');

