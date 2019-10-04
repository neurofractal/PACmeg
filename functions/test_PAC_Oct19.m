cd('/Users/rseymoue');
load('test123.mat');

figure; plot(signal(1:2200))

cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [2:1:10];
cfg.amp_freqs           = [30:2:100];
cfg.method              = 'tort';
cfg.filt_order          = 3;
cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 16;

[MI_raw,MI_surr]        = PACmeg(cfg,signal);

ddd = (fff - squeeze(mean(ggg,1)))./((squeeze(mean(ggg,1)))).*100;

ddd(find(ddd < 0)) = 0;

plot_comod(cfg.phase_freqs,cfg.amp_freqs,ddd)
