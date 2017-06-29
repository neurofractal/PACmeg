%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 5_visual_PAC_four_methods.m
%
%
% Script to compute PAC comodulograms for the pre and post grating period,
% using V1 VE data. Four PAC algorithms are currently implemented.
%
% Each approach calculates PAC for 64 trials * 16 
% participants * 7 phase frequencies and 34 amplitude frequencies. This  
% will take some time. If performance is slow the user might 
% wish to run the algorithms in parallel using 4 separate MATLAB windows.
%
% Once completed, the PAC comodulograms are statistically compared 
% and the results are plotted. It is worth doing this part separately for
% each algorithm.
%
% Written by Robert Seymour - June 2017
%
% Computation time: 4-6 hours
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

%% Start loop for all subjects
for sub = 1:length(subject)
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tort et al., (2008)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     % Load in data and cd to the right place
    cd([scripts_dir '\' subject{sub}])
    load([scripts_dir '\' subject{sub} '\VE_V1.mat']);
    
     % Add path to PAC functions
    addpath(scripts_dir)

     % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no');
    save matrix_post_tort matrix_post;  

    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no')
    save matrix_pre_tort matrix_pre;
    
    clear matrix_post matrix_pre

    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ozkurt et al., (2010)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_ozkurt(VE_V1,[0.3 1.5],[7 13],[34 100],'no');
    save matrix_post_ozkurt matrix_post; 

    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_ozkurt(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no')
    save matrix_pre_ozkurt matrix_pre;  

    clear matrix_post matrix_pre
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Canolty et al., (2006)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_canolty(VE_V1,[0.3 1.5],[7 13],[34 100],'no');
    save matrix_post_canolty matrix_post; clear MI_matrix  

    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_canolty(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no')
    save matrix_pre_canolty matrix_pre; 

    clear matrix_post matrix_pre
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLV
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_PLV(VE_V1,[0.3 1.5],[7 13],[34 100],'no');
    save matrix_post_PLV matrix_post; clear MI_matrix  

    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_PLV(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no')
    save matrix_pre_PLV matrix_pre;
    
    clear matrix_post matrix_pre
    
end


cd(scripts_dir)

%% Statistical Analysis

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Canolty et al., (2006) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_canolty] = get_PAC_stats('matrix_post_canolty.mat',...
    'matrix_pre_canolty',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_canolty, [7 13], [34 100]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ozkurt et al., (2011) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_ozkurt] = get_PAC_stats('matrix_post_ozkurt.mat',...
    'matrix_pre_ozkurt',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_ozkurt, [7 13], [34 100]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cohen et al., (2008) - PLV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_PLV] = get_PAC_stats('matrix_post_PLV.mat',...
    'matrix_pre_PLV',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_PLV, [7 13], [34 100]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tort et al., (2010) - MI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_tort] = get_PAC_stats('matrix_post_tort.mat',...
    'matrix_pre_tort.mat',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_tort, [7 13], [34 100]);
