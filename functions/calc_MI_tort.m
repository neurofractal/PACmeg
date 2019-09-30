
function [MI] = calc_MI_tort(Phase,Amp,nbin)

% Apply Tort et al (2010) approach)
%nbin=18; % % we are breaking 0-360o in 18 bins, ie, each bin has 20o
position=zeros(1,nbin); % this variable will get the beginning (not the center) of each bin
% (in rads)
winsize = 2*pi/nbin;
for j=1:nbin
    position(j) = -pi+(j-1)*winsize;
end

% now we compute the mean amplitude in each phase:
MeanAmp=zeros(1,nbin);
for j=1:nbin
    I = find(Phase <  position(j)+winsize & Phase >=  position(j));
    MeanAmp(j)=mean(Amp(I));
end

% The center of each bin (for plotting purposes) is
% position+winsize/2

% Plot the result to see if there's any amplitude modulation
% if strcmp(diag, 'yes')
%     bar(10:20:720,[MeanAmp,MeanAmp]/sum(MeanAmp),'phase_freq')
%     xlim([0 720])
%     set(gca,'xtick',0:360:720)
%     xlabel('Phase (Deg)')
%     ylabel('Amplitude')
% end

% Quantify the amount of amp modulation by means of a
% normalized entropy index (Tort et al PNAS 2008):

MI=(log(nbin)-(-sum((MeanAmp/sum(MeanAmp)).*log((MeanAmp/sum(MeanAmp))))))/log(nbin);
end