%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function performs statistical analyis on the matrix of modulation 
% index (MI) values computed for PAC analysis.
%
% The script loads the comodulogram and adds the necessary info to make 
% into a FT data structure.
%
% Group statistics are then computed using cluster-based permutation tests 
% based on the Montercarlo method (Maris & Oostenveld, 2007).
%
% Inputs:
% - PAC_name1 = name of the first comdoulogram (specific to my data - can
% be changed)
% - PAC_name2 = name of the second comodulogram (specific to my data - can
% be changed)
% - phase = phase range
% - amp = amplitude range
% - subject = subject list
% - scripts_dir = where the data & scripts are stored
%
% Outputs:
% - stat = statistical output
%
% Written by Robert Seymour (ABC) - January 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stat] = get_PAC_stats(PAC_name1,PAC_name2,phase,amp,subject,scripts_dir,surr)

amp_list = [amp(1):2:amp(2)]; phase_list = [phase(1):1:phase(2)];

grandavgA = [];

for i =1:length(subject)
    
    % load PAC1
    load([scripts_dir '\' subject{i} '\' PAC_name1]); % non-ICA'd data
    % Add FT-related data structure information
    MI_post = [];
    MI_post.label = {'MI'};
    MI_post.dimord = 'chan_freq_time';
    MI_post.freq = amp_list;
    MI_post.time = phase_list;
    % if loading surrogates then the name of the variable is
    % matrix_XXX_surrogates
    if surr == 1
        MI_post.powspctrm = matrix_post_surrogates;
    % if loading raw MI estimate then the name of the variable is
    % matrix_XXX   
    else
        MI_post.powspctrm = matrix_post;
    end
    MI_post.powspctrm = reshape(MI_post.powspctrm,[1,length(amp_list),length(phase_list)]);
    % Add to meta-matrix
    grandavgA{i} = MI_post;
    clear matrix_post MI_post
end

grandavgB = [];

% Repeat for matrix_pre
for i =1:length(subject)
    
    % load matrix_pre
    load([scripts_dir '\' subject{i} '\' PAC_name2]); % non-ICA'd data
    % Add FT-related data structure information
    MI_pre = [];
    MI_pre.label = {'MI'};
    MI_pre.dimord = 'chan_freq_time';
    MI_pre.freq = amp_list;
    MI_pre.time = phase_list;
    % if loading surrogates then the name of the variable is
    % matrix_XXX_surrogates
    if surr == 1
        MI_pre.powspctrm = matrix_pre_surrogates;
    % if loading raw MI estimate then the name of the variable is
    % matrix_XXX 
    else
        MI_pre.powspctrm = matrix_pre;
    end
    MI_pre.powspctrm = reshape(MI_pre.powspctrm,[1,length(amp_list),length(phase_list)]);
    % Add to meta-matrix
    grandavgB{i} = MI_pre;
    clear matrix_pre MI_post
end

%% Perform Stats
cfg=[];
cfg.latency = 'all';
cfg.frequency = 'all';
cfg.dim         = grandavgA{1}.dimord;
cfg.method      = 'montecarlo';
cfg.statistic   = 'ft_statfun_depsamplesT';
cfg.parameter   = 'powspctrm';
cfg.correctm    = 'cluster';
cfg.computecritval = 'yes';
cfg.numrandomization = 1000;
cfg.alpha       = 0.05; % Set alpha level
cfg.tail        = 0;    % Two sided testing

% Design Matrix
nsubj=numel(grandavgA);
cfg.design(1,:) = [1:nsubj 1:nsubj];
cfg.design(2,:) = [ones(1,nsubj) ones(1,nsubj)*2];
cfg.uvar        = 1; % row of design matrix that contains unit variable (in this case: subjects)
cfg.ivar        = 2; % row of design matrix that contains independent variable (the conditions)

stat = ft_freqstatistics(cfg,grandavgA{:}, grandavgB{:});

%% Compute group difference between matrix_post and matrix_pre
cfg = [];
post_MI = ft_freqgrandaverage(cfg,grandavgA{:})
pre_MI = ft_freqgrandaverage(cfg,grandavgB{:})

cfg = [];
cfg.parameter = 'powspctrm';
cfg.operation = 'subtract';
diff_MI = ft_math(cfg,post_MI,pre_MI)

cfg = [];
cfg.zlim = 'maxabs';
cfg.ylim = amp;
cfg.xlim    = phase;
ft_singleplotTFR(cfg,diff_MI); colormap(jet);

%% Display results of stats (very rough - use make_smoothed_comodulograms)
cfg=[];
cfg.parameter = 'stat';
cfg.maskparameter = 'mask';
cfg.maskstyle     = 'outline';
cfg.zlim = 'maxabs';
fig = figure; 
ft_singleplotTFR(cfg,stat); colormap('jet');
xlabel('Phase (Hz)'); ylabel('Amplitude (Hz)');

end


