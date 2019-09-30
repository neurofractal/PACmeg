    function [MI] = calc_MI_ozkurt(Phase,Amp)
        % Apply the algorithm from Ozkurt et al., (2011)
        N = length(Amp);
        z = Amp.*exp(1i*Phase); % Get complex valued signal
        MI = (1./sqrt(N)) * abs(mean(z)) / sqrt(mean(Amp.*Amp)); % Normalise
    end