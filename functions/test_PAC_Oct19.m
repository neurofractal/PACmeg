cd('/Users/rseymoue');
load('test_trial.mat');

figure; plot(PAC_signal(2,1:4000));

signal = vertcat(VE.trial{:});

cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [2:1:10];
cfg.amp_freqs           = [30:2:200];
cfg.method              = 'tort';
cfg.filt_order          = 3;
%cfg.mask                = [691 1051];
cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 20;
%[MI_raw]        = PACmeg(cfg,PAC_signal);
[MI_raw,surr]        = PACmeg(cfg,PAC_signal);

N = (MI_raw - squeeze(mean(surr)));

plot_comod(cfg.phase_freqs,cfg.amp_freqs,N)

