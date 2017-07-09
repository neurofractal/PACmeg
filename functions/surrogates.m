%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script performs PAC surrogate analysis 
%
% 
%
% Written by Robert Seymour - June 2017
%
% Running-time: 15-20 minutes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load computer-specific information
restoredefaultpath
sensory_PAC;
addpath(fieldtrip_dir);
ft_defaults

matrix_post_all = [];
matrix_pre_all = [];


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
    [matrix_post] = calc_MI_tort(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes');
    save matrix_post_tort_surrogates matrix_post;  
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_tort(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes')
    save matrix_pre_tort_surrogates matrix_pre;
    
    clear matrix_post matrix_pre 
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ozkurt et al., (2010)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   
     % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_ozkurt(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes');
    save matrix_post_ozkurt_surrogates matrix_post;  
    
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_ozkurt(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes')
    save matrix_pre_ozkurt_surrogates matrix_pre;
    
    clear matrix_post matrix_pre 

    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Canolty et al., (2006)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
     % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_canolty(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes');
    save matrix_post_canolty_surrogates matrix_post;  
    
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_canolty(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes');
    save matrix_pre_canolty_surrogates matrix_pre;
    
    clear matrix_post matrix_pre 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % PLV
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
     % Get comod for post grating (0.3 to 1.5s) period
    [matrix_post] = calc_MI_PLV(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes');
    save matrix_post_PLV_surrogates matrix_post;  
    
    % Get comod for pre grating (-1.5 to -0.3s) period
    [matrix_pre] = calc_MI_PLV(VE_V1,[-1.5 -0.3],[7 13],[34 100],'no','yes');
    save matrix_pre_PLV_surrogates matrix_pre;
    
    clear matrix_post matrix_pre
    
end


%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Canolty et al., (2006) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_canolty] = get_PAC_stats('matrix_post_canolty_surrogates.mat',...
    'matrix_pre_canolty_surrogates',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_canolty, [7 13], [34 100]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ozkurt et al., (2011) - MVL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_ozkurt] = get_PAC_stats('matrix_post_ozkurt_surrogates.mat',...
    'matrix_pre_ozkurt_surrogates',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_ozkurt, [7 13], [34 100]);

end

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cohen et al., (2008) - PLV
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[stat_PLV] = get_PAC_stats('matrix_post_PLV_surrogates.mat',...
    'matrix_pre_PLV_surrogates',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_PLV, [7 13], [34 100]);

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tort et al., (2010) - MI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[stat_tort] = get_PAC_stats('matrix_post_tort_surrogates.mat',...
    'matrix_pre_tort_surrogates.mat',[7 13],[34 100],subject,scripts_dir) 

make_smoothed_comodulograms(stat_tort, [7 13], [34 100]);
