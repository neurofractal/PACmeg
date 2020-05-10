
% Adjust paths for your machine
path_to_fieldtrip   = '/Users/rseymoue/Documents/scripts/fieldtrip-20191213';
path_to_pacMEG      = '/Users/rseymoue/Documents/GitHub/PACmeg';

% Add Fieldtrip + PACmeg to your MATLAB path
addpath(path_to_fieldtrip); ft_defaults;
addpath(genpath(path_to_pacMEG));

% Specify parameter for synthesising PAC
fnesting        = 4;
fnested         = 60;
duration        = 10;
sRate           = 1000;
couplingPhase   = 90;
DutyCycle       = 0.5;
SNR             = 6;
PACstr          = 0.9;

% Synthesise PAC signal
PAC_signal = synthesise_pac(fnesting, fnested, duration, sRate, ...
    couplingPhase, DutyCycle, SNR, PACstr);

% Plot a 
figure; 
set(gcf,'Position',[100 100 1600 800]);
plot(PAC_signal(1:3000),'r','LineWidth',10);

% Calculate PAC

list_of_methods = {'tort','ozkurt','plv','canolty'};

for method = 1:length(list_of_methods);
    
    cfg                     = [];
    cfg.Fs                  = 1000;
    cfg.phase_freqs         = [2:1:8];
    cfg.amp_freqs           = [30:2:100];
    cfg.method              = list_of_methods{method};
    cfg.filt_order          = 3;
    %cfg.mask               = [691 1051];
    %cfg.surr_method         = 'swap_blocks';
    cfg.surr_N              = 200;
    cfg.amp_bandw_method    = 'number';
    cfg.amp_bandw           = 10;
    [MI_raw]                = PACmeg(cfg,PAC_signal);
    
    plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);
    title(list_of_methods{method},'FontSize',20);
    colorbar;
    drawnow;
end


