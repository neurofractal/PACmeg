function plot_comod(phase_freqs,amp_freqs,MI_matrix_raw)



figure; imagesc(phase_freqs,amp_freqs, MI_matrix_raw);
view([0 -90]);
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap
caxis([-max(MI_matrix_raw(:)) max(MI_matrix_raw(:))]);
xticks(phase_freqs);
yticks(min(amp_freqs):20:max(amp_freqs));
set(gca,'FontSize',14);
xlabel('Phase Frequencies (Hz)','FontSize',18);
ylabel('Amplitude Frequencies (Hz)','FontSize',18);