cd('/Users/rseymoue');
load('test123.mat');

figure; plot(signal(1:2200))

cfg = [];
cfg.Fs            = 1000;
cfg.phase_freqs   = [2:1:15];
cfg.amp_freqs     = [20:2:300];
cfg.method        = 'tort';
cfg.filt_order    = 3;
cfg.amp_bandw_method = 'number';
cfg.amp_bandw     = 16;

fff = PACmeg(cfg,signal);

plot_comod(cfg.phase_freqs,cfg.amp_freqs,fff)
