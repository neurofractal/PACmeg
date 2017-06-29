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
shading interp; colormap(jet);hold on; colorbar; %shading, colorbar
contour(phase(1):1:phase(2),amp(1):2:amp(2),mask_reshaped,v,'--','Color','black','LineWidth',3) %stats mask
ylabel('Amplitude (Hz)'); xlabel('Phase (Hz)') %axis labels

set(gca,'FontName','Arial');
set(gca,'FontSize',15);
set(gcf, 'Color', 'w');
end
