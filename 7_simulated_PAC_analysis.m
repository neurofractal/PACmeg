%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 7_simulated_PAC_analysis.m
%
% This script produces synthesised PAC between 10-11Hz and 50-70Hz. 3 PAC
% algorithms are then applied to determine how well they recover this
% coupling.
%
% The coupling between 10Hz and 60Hz is then calculated as a function of
% data length, to determine how many seconds of data are needed for 
% reliable estimates of PAC.
%
% N.B. Due to the use of random noise values, the resulting plots may vary
% slightly from the Seymour, Kessler & Rippon (2017) manuscript.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath
PAC_frontiers_dir;
addpath(fieldtrip_dir);
ft_defaults

%% Show an example of the Synthesised PAC
[s_final, snr] = synthesize_pac(2);
figure; plot(s_final(1:1000));

%% Create 64 different SNRs

for i = 1:64
    snr_array(i) = (3*rand(1,1));
end

%% Create Fieldtrip-like Virtual Electrode with 64 trials of synthesised PAC
VE_PAC = [];
VE_PAC.label = {'PAC'};
for i = 1:64 % for every trial
    % syntheise PAC using a different noise value
    [s_final, snr] = synthesize_pac(snr_array(i));
    VE_PAC.trial{1,i} = s_final(1:10000); % Put simulated PAC into Fieldtrip VE
    VE_PAC.time{1,i} = 0.001:0.001:10; % Create 10s worth of PAC
    VE_PAC.trialinfo(i,1) = 1;
    disp(['Trial ' num2str(i)]);
end

%% Create comodulogram using the Ozkurt method
ozkurt_PAC = calc_MI_ozkurt(VE_PAC,[0.3 1.5],[7 13],[34 100],'no');

figure; 
pcolor([7:1:13],[34:2:100],ozkurt_PAC); shading(gca,'interp');
colormap(jet); xlabel('Phase (Hz)');ylabel('Amplitude (Hz)');
title('MLV-MI');
set(gca,'FontName','Arial');
set(gca,'FontSize',15); colorbar;

%% Create comodulogram using the Tort method
tort_PAC = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no');

figure; 
pcolor([7:1:13],[34:2:100],tort_PAC); shading(gca,'interp');
colormap(jet);
colormap(jet); xlabel('Phase (Hz)');ylabel('Amplitude (Hz)');
title('KL-MI');
set(gca,'FontName','Arial');
set(gca,'FontSize',15); colorbar;

%% Create comodulogram using the Cohen PLV method
PLV_PAC = calc_MI_PLV(VE_PAC,[0.3 1.5],[7 13],[34 100],'no');

figure; 
pcolor([7:1:13],[34:2:100],PLV_PAC); shading(gca,'interp');
colormap(jet);
colormap(jet); xlabel('Phase (Hz)');ylabel('Amplitude (Hz)');
title('PLV-PLV');
set(gca,'FontName','Arial');
set(gca,'FontSize',15); colorbar;

%% How does PAC vary with trial length?
MI_ozkurt = [];

for k = 1:100 % 0.1-10s in 0.1s steps
    MI_ozkurt(k) = calc_MI_ozkurt(VE_PAC,[0 (k/10)],[10 10],[60 60],'no');
end

MI_tort = []; % 0.1-10s in 0.1s steps

for k = 1:100
    MI_tort(k) = calc_MI(VE_PAC,[0 (k/10)],[10 10],[60 60],'no');
end

MI_PLV = []; % 0.1-10s in 0.1s steps

for k = 1:100
    MI_PLV(k) = calc_MI_PLV(VE_PAC,[0 (k/10)],[10 10],[60 60],'no');
end

% Plot results (Ozkurt)
figure;plot([0.1:0.1:10],MI_ozkurt,'LineWidth',3);
xlabel('Trial Length (s)');ylabel('MI Value');
xticks = ([0:1:10]);
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
set(gca,'XTick',xticks);
title('MVL-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
set(gca,'XTick',xticks);

% Plot Results (Tort)
figure; plot([0.1:0.1:10],MI_tort,'r','LineWidth',3); hold on;
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
title('KL-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
set(gca,'XTick',xticks);

% Plot Results (PLV)
figure; plot([0.1:0.1:10],MI_PLV,'Color',[0 0.7 0.2],'LineWidth',3); hold on;
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
title('PLV-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',15);
set(gca,'XTick',xticks);
