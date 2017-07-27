function make_smoothed_comodulograms(stat, phase, amp)

% Reshape the necessary data
stats_reshaped = squeeze(stat.stat);
mask_reshaped = squeeze(stat.mask);
v = [1];

% Create the figure
figure('color', 'w');
pcolor(phase(1):1:phase(2),amp(1):2:amp(2),stats_reshaped); % colormap
axislim = max(stat.stat(:));
caxis([-axislim axislim]) %threshold
shading interp; colormap(jet);hold on; c =colorbar; %shading, colorbar
contour(phase(1):1:phase(2),amp(1):2:amp(2),mask_reshaped,v,'--','Color','black','LineWidth',3) %stats mask
set(gca,'FontSize',30);
ylabel('Amplitude Frequency (Hz)','FontSize',25); xlabel('Phase Frequency (Hz)','FontSize',25) %axis labels
ylabel(c,'t-value','FontSize',25);

set(gca,'FontName','Arial');
set(gcf, 'Color', 'w');
set(gca,'XTick',[phase(1):1:phase(2)]);

end
