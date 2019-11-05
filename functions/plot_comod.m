function plot_comod(phase_freqs,amp_freqs,MI_matrix_raw)
figure; imagesc(phase_freqs,amp_freqs, MI_matrix_raw);
view([0 -90]);
try
ft_hastoolbox('brewermap', 1);         % ensure this toolbox is on the path
colormap(flipud(brewermap(64,'RdBu'))) % change the colormap

catch
    disp('Using default colormap');
end

% Adjust axis limits
caxis([-max(MI_matrix_raw(:)) max(MI_matrix_raw(:))]);

xticks(phase_freqs);
yticks(min(amp_freqs):20:max(amp_freqs));
set(gca,'FontSize',20);
xlabel('Phase Frequencies (Hz)','FontSize',25);
ylabel('Amplitude Frequencies (Hz)','FontSize',25);
end