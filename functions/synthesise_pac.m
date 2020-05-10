%% ===== GENERATE SIGNALS =====
function yOut = synthesise_pac(fnesting, fnested, duration, sRate, couplingPhase, DutyCycle, SNR, PACstr)
% Generate synthetic example of phase-amplitude coupled oscillations
%
% INPUTS:
%    - fnesting:      Frequency of phase driver (in Hz)
%    - fnested:       Frequency of high-frequency nested bursts (in Hz)
%    - duration:      Signal duration (in seconds)
%    - sRate:         Sampling rate (in Hz)
%    - couplingPhase: The phase in which the nested signal is coupled to the nesting signal
%    - DutyCycle:     Duty cycle of nesting signal in the case of asymmetry
%    - SNR:           Signal to noise ration (dB)(default: 6 dB)
%    - PACstr:        Strength of coupling [0-1] (default: 1)
%
% Author: Soheila Samiee, 2013
%

    % Default: coupling in peaks of nesting signal
    if (nargin < 5) || isempty(couplingPhase)
        couplingPhase = 90;     
    end
    if (nargin < 6) || isempty(DutyCycle)
        DutyCycle = .5;
    end
    if (nargin < 7) || isempty(SNR)
        SNR = 6;
    end
    if (nargin < 8) || isempty(PACstr)
        PACstr = 1;
    end
    
    % Parameters
    chi = 1-PACstr;
    methodT = 'nHan';%'Han';            % Type of adding nested signal to nested signal
    NestedAmp = 0.1;            % Amplitude of nested signal
    
    % Generate time vector
    if strcmp(methodT,'Han') && DutyCycle~=.5
        lag = fix(couplingPhase/360*sRate);
    else
        lag = 0;
    end
    T = 1/sRate;
    t = 0:T:duration+lag*T;
    
    % ===== NOISE ======
    % Generating the noise
    [tmp,noise] = phase_noise(length(t),1,-1,100);       % applying 1/f distribution to noise
%     noise = randn(1,length(t));
    signal_power = (1/sqrt(2))^2;
    noise_power = (std(noise))^2;
    noiseLev = (signal_power/10^(SNR/10));  % SNR is in dB = 20 log S/N = 10 log P(S)/P(N)
    noise = .66* noiseLev/noise_power * noise + noiseLev/3 *randn(1,length(t));
    
    % ===== NESTING SIGNAL =====
    % Generating the nesting signal
    if (DutyCycle ~= 0.5)
        k = DutyCycle;
        T = 1/fnesting;
        b = (1-2*k^2)/(2*k*T*(1-k));
        a = (1-b*T)/T^2;
        ynesting = sin(2*pi*(a*mod(t,T)+b).*mod(t,T)-pi/2);
    else
        ynesting = sin(2*pi*fnesting*t - pi/2);
    end

    % ===== NESTED SIGNAL =====
    % Estimation of phase of nesting signal 
    if strcmp(methodT,'Han')
        
        [ymax,imax,ymin,imin] = extrema(ynesting);
        imax = imax(abs(ymax) > .95);
        imin = imin(abs(ymin) > .95);
        iZeros = find(diff([0 sign(ynesting)])==2 | diff([0 sign(ynesting)])==-2 | sign(ynesting)==0);
        if iZeros(end)==length(ynesting)
            iZeros = iZeros(1:end-1);
        end
        AscZeros = iZeros(ynesting(iZeros+1)-ynesting(iZeros) > 0);
        DescZeros = iZeros(ynesting(iZeros+1)-ynesting(iZeros) < 0);
        endpoints = AscZeros(AscZeros > 1) - 1;
        
        % Linear estimation of phase:
        % estimatedphase(imax) => 90
        % estimatedphase(imin) => 270
        % estimatedphase(AscZeros) => 0
        % estimatedphase(DescZeros) => 180
        % estimatedphase(endpoints) => 360
        estimatedphase = interp1(t([imax,imin,AscZeros,DescZeros,endpoints]), ...
            [repmat(90,1,length(imax)),repmat(270,1,length(imin)), ...
            repmat(0,1,length(AscZeros)),repmat(180,1,length(DescZeros)), ...
            repmat(360,1,length(endpoints))],t,'linear');
        
        % Generating the nested signal
        nested_duration = 1/(fnesting); % duration of nested bursts %%%%% can be changed
        tt = 0:1/sRate:nested_duration;
        ll = fix(length(tt)/2);
        
        % Find the corresponding samples to "coupling phase"
        iphase = find(diff([0 sign(estimatedphase-couplingPhase)])==2 | sign(estimatedphase-couplingPhase)==0);
        iphase = iphase + round(rand(size(iphase))*sRate/fnested/4);  % shifting the peak of nested signal randomly
        
        baselineR = NestedAmp * 1/(1+strInd);    % baseline ratio of nested frequency
        mainR = NestedAmp * strInd/(1+strInd);
        ynested = baselineR * sin(2*pi*(fnested*t + 3*pi/7));
        % Loop on each desired phase of nesting cycle
        for k = 1:length(iphase)
            % Time indices where to add the nested bursts
            idx = round(max([iphase(k)-ll+1, 1]):min([iphase(k)+ll, length(t)]));
            % Generate nested signal
            % FIRST METHOD: Hanning window
            % Use hanning window on nested signal, and not change the amplitude
            % of nesting signal with amplitude of nested signal as envelope. This
            % is important especially when we want to add nesting signal in
            % ascending or descending phase instead of peaks or troughs
            % NOTE: If we apply hanning window, usually the coupling power extends
            % in nested frequency if we estimate the PAC using PACestimate.
            ynestedMain = mainR * hann(length(idx))' .* sin(2*pi*(fnested*t(idx) + 3*pi/7));
            % Adding: main + baseline
            ynested(idx) = ynested(idx) + ynestedMain;
        end
    else
        % SECOND METHOD: Nesting signal amplitude modulation
        % Use nesting signal amplitude instead of Hanning window to modulate
        % the amplitude of nested signal (Same as nestingnested function).
        % It can just be used for "coupling phase = 90"
        if DutyCycle == .5
            ynested = (NestedAmp*((1-chi)* sin(2*pi*fnesting*t - pi/2+couplingPhase/180*pi)+1+chi)/2).*sin(2*pi*fnested*t);
        else
            ynesting2 = ynesting(lag+1:end);
            ynested = (NestedAmp*((1-chi)* ynesting2 +1+chi)/2).*sin(2*pi*fnested*t(1:end-lag));
        end   
    end
    
    % ===== OUTPUT SIGNAL =====
    % Adding: nesting + nested + noise
    noise = noise(1:end-lag);
    ynesting = ynesting(1:end-lag);
    yOut = ynesting + ynested + noise;
    
end