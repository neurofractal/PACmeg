cd('/Users/rseymoue/Documents/GitHub/PACmeg/artificial_PAC');
load('signal1.mat');

figure; plot(signal_all(1,5:3000));

cfg                     = [];
cfg.Fs                  = 1000;
cfg.phase_freqs         = [8:1:16];
cfg.amp_freqs           = [30:2:100];
cfg.method              = 'plv';
cfg.filt_order          = 4;
%cfg.mask                = [691 1051];
cfg.surr_method         = 'swap_blocks';
cfg.surr_N              = 200;
cfg.amp_bandw_method    = 'number';
cfg.amp_bandw           = 20;
[MI_raw,surr]           = PACmeg(cfg,signal_all);

N = (MI_raw - squeeze(mean(surr,1)));

plot_comod(cfg.phase_freqs,cfg.amp_freqs,MI_raw);

