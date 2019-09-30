
    function [MI] = calc_MI_canolty(Phase,Amp)
        % Apply MVL algorith, from Canolty et al., (2006)
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = abs(mean(z));
    end