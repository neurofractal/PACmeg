%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% synthesize_pac.m
%
% Function to simulate a signal containing phase-amplitude coupling
% between the phase of a low frequency (10-11Hz Hz) and amplitude of a
% high-freqency band (50-70 Hz) for a chosen noise level. Hamming tapered
% high frequency signal is added at each cycle of low frequency component.
% sampling frequency is chosen as 1000 Hz.

% Code is adapted from Kramer et al. (2008), Jrn. Nrsc. Methds. 
% and Ozkurt et al., (2011) Jrn. Nrsc. Methds.

% Inputs: 
% - noise lev : parameter describing the noise power

% Outputs:
% - snr : signal-to-noise ratio
% - s_final: the synthesized signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s_final, snr] = synthesize_pac(noise_lev)

dt = 0.001;
s = [];
for k=1:400
    f = rand()*1.0+10.0;                 %Create the low freq (10 Hz) signal.
    s1 = cos(2.0*pi*(0:dt*f:1-dt*f));
    good = find(s1 < -0.99);
    s2 = zeros(1,length(s1));
 
    stemp = randn(1,3000);                 %Create noisy data.
    stemp = ft_preproc_bandpassfilter(stemp, 1000, [50 70]);%Make high freq (50-70 Hz) signal.
    stemp = stemp(2000:2039);             %Duration 50 ms.
    stemp = 5*hanning(40)'.*stemp;      %Hanning tapered.
    
    rindex = ceil(rand()*2);       %Add the high frequency in,
						%when the low frequency is near 0 phase.
    s2(rindex + good(1) - 20:rindex+good(1)+20-1)=stemp;
    s = [s, s1+1*s2];
end

% Generate noise and calculate SNR
n = noise_lev*randn(1,length(s));
snr = 10 * log10((s*s') / (n*n'));

% Add in noise
s = s + n;
s = s(1:12000);
sCropped = s(1000:11000-1);

s_final = sCropped; 
