%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 7_simulated_PAC_analysis.m
%
% This script produces synthesised PAC between 10-11Hz and 50-70Hz. 4 PAC
% algorithms are then applied to determine how well they recover this
% coupling.
%
% PAC between 10Hz and 60Hz is then calculated as a function of
% data length, to determine how many seconds of data are needed for 
% reliable estimates.
%
% N.B. Due to the use of random noise values, the resulting plots may vary
% slightly from the Seymour, Kessler & Rippon (2017) manuscript.
%
% Written by: Robert Seymour, June 2017
%
% Please note that these scripts have been optimised for the Windows
% operating systm and MATLAB versions about 2014b.
%
% Runtime: 10 minutes
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load computer-specific information
restoredefaultpath
sensory_PAC;
addpath(fieldtrip_dir);
addpath(genpath(scripts_dir));
ft_defaults

% If you do not run these lines you will have to manually specify:
% - data_dir = directory which contains the MEG & anatomical information
% - scripts_dir = directory with ALL the scripts
% - fieldtrip_dir = directory containing the Fieldtrip toolbox

%% Show an example of the Synthesised PAC
[s_final, snr] = synthesize_pac(2);
figure; plot(s_final(1:1000));

%% Create 64 different SNRs

rng('default'); rng(1)
snr_array = rand(64,1)*3

%% Create Fieldtrip-like Virtual Electrode with 64 trials of synthesised PAC
VE_PAC = [];
VE_PAC.label = {'PAC'};
for i = 1:64 % for every trial
    % syntheise PAC using a variable noise value
    [s_final, snr] = synthesize_pac(snr_array(i));
    VE_PAC.trial{1,i} = s_final(1:10000); % Put simulated PAC into Fieldtrip VE
    VE_PAC.time{1,i} = 0.001:0.001:10; % Create 10s worth of PAC
    VE_PAC.trialinfo(i,1) = 1;
    disp(['Trial ' num2str(i)]);
    VE_PAC.sampleinfo(i,:) = [10000*i 10000*i+9999];
end


%% Create comodulogram using the Ozkurt method
canolty_PAC = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','canolty');

figure; xticks = [7:1:13];
pcolor([7:1:13],[34:2:100],canolty_PAC); shading(gca,'interp'); 
colormap(jet);
set(gca,'FontSize',30);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
%title('MVL-MI-Canolty');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);


%% Create comodulogram using the Ozkurt method
ozkurt_PAC = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','ozkurt');

figure; xticks = [7:1:13];
pcolor([7:1:13],[34:2:100],ozkurt_PAC); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',30);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
%title('MVL-MI-ozkurt');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);

%% Create comodulogram using the Tort method
tort_PAC = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','tort');

figure; xticks = [7:1:13];
pcolor([7:1:13],[34:2:100],tort_PAC); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',30);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
%title('MVL-MI-Tort');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);


%% Create comodulogram using the Cohen PLV method
PLV_PAC = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','PLV');

figure; xticks = [7:1:13];
pcolor([7:1:13],[34:2:100],PLV_PAC); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',30);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
%title('MVL-MI-PLV');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);

%% How does PAC vary with trial length?

MI_canolty = []; % 0.1-10s in 0.1s steps

for k = 1:100
    MI_canolty(k) = calc_MI(VE_PAC,[0 (k/10)],[10 10],[60 60],'no','no','canolty');
end

MI_ozkurt = [];

for k = 1:100 % 0.1-10s in 0.1s steps
    MI_ozkurt(k) = calc_MI(VE_PAC,[0 (k/10)],[10 10],[60 60],'no','no','ozkurt');
end

MI_tort = []; % 0.1-10s in 0.1s steps

for k = 1:100
    MI_tort(k) = calc_MI(VE_PAC,[0 (k/10)],[10 10],[60 60],'no','no','tort');
end

MI_PLV = []; % 0.1-10s in 0.1s steps

for k = 1:100
    MI_PLV(k) = calc_MI(VE_PAC,[0 (k/10)],[10 10],[60 60],'no','no','PLV');
end

xticks = ([0:1:10]);

% Plot results (Canolty)
figure;plot([0.1:0.1:10],MI_canolty,'Color',[0.5 0 0.6],'LineWidth',6);
title('MVL-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',30);
set(gca,'XTick',xticks);

% Plot results (Ozkurt)
figure;plot([0.1:0.1:10],MI_ozkurt,'LineWidth',6);
title('MVL-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',30);
set(gca,'XTick',xticks);

% Plot Results (Tort)
figure; plot([0.1:0.1:10],MI_tort,'r','LineWidth',6); hold on;
title('KL-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',30);
set(gca,'XTick',xticks);

% Plot Results (PLV)
figure; plot([0.1:0.1:10],MI_PLV,'Color',[0 0.7 0.2],'LineWidth',6); hold on;
title('PLV-MI');
xlabel('Trial Length (s)');ylabel('MI Value');
set(gca,'FontName','Arial');
set(gca,'FontSize',30);
set(gca,'XTick',xticks);

%% How does number of bins affect the MI-KL-Tort approach?

tort_PAC_9_bins = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','tort',9);
tort_PAC_18_bins = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','tort',18);
tort_PAC_36_bins = calc_MI(VE_PAC,[0.3 1.5],[7 13],[34 100],'no','no','tort',36);

% Plot results
figure; xticks = [7:1:13]; subplot(1,3,1);
pcolor([7:1:13],[34:2:100],tort_PAC_9_bins); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',15);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
title('9 Bins');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);

subplot(1,3,2);
pcolor([7:1:13],[34:2:100],tort_PAC_18_bins); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',15);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
title('18 Bins');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);

subplot(1,3,3);
pcolor([7:1:13],[34:2:100],tort_PAC_36_bins); shading(gca,'interp'); 
colormap(jet); colorbar;
set(gca,'FontSize',15);
xlabel('Phase Frequency (Hz)','FontSize',25);ylabel('Amplitude Frequency (Hz)','FontSize',25);
title('36 Bins');
set(gca,'FontName','Arial');
set(gca,'XTick',xticks);
set(gcf,'Position',[6 558 1908 420])






