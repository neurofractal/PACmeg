    function [MI] = cohen_PLV(Phase,Amp)
        % Apply PLV algorith, from Cohen et al., (2008)
        amp_phase = angle(hilbert(detrend(Amp))); % Phase of amplitude envelope
        MI = abs(mean(exp(1i*(Phase-amp_phase))));
    end