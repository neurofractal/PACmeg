# PACmeg

MATLAB scripts for detecting and validating **phase amplitude coupling (PAC)** in electrophysiological data.

Written and maintained by **[Robert Seymour](http://robertseymour.me)**, June 2017.

![PACmeg](https://github.com/neurofractal/PACmeg/blob/master/figures_and_results/PAC_figure4-1.jpg)

## Manuscript & Citation

**Seymour, R. A., Rippon, G., & Kessler, K. (2017). The Detection of Phase Amplitude Coupling During Sensory Processing. Frontiers in Neuroscience 11, 487. https://doi.org/10.3389/fnins.2017.00487**

The pre-print of the manuscript is available to download on [Biorxiv](https://doi.org/10.1101/163006), and the published manuscript is available to download on the [Frontiers website](https://doi.org/10.3389/fnins.2017.00487).

## Data Sharing

Please download the MEG and anatomical data from [Figshare](https://figshare.com/collections/The_Detection_of_Phase_Amplitude_Coupling_During_Sensory_Processing/3819106).

Scripts can be easily adapted for your computer by modifying the sensory_PAC.m script:

```matlab
data_dir = 'path_to_data';
scripts_dir = 'path_to_scripts';
fieldtrip_dir = 'path_to_fieldtrip';
subject = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06','sub-07',...
    'sub-08','sub-09','sub-10','sub-11','sub-12','sub-13','sub-14',...
    'sub-15','sub-16'};
```

Fieldtrip version 20161024 was used during data analysis, and can be found from the /fieldtrip folder.

## Analysis should be performed in the following order:

* [1_preprocessing_elektra_frontiers_PAC.m](https://github.com/neurofractal/PACmeg/blob/master/1_preprocessing_elektra_frontiers_PAC.m) = this script performs simple preprocessing steps and removes bad trials

* [2_get_source_power.m](https://github.com/neurofractal/PACmeg/blob/master/2_get_source_power.m) = this script performs source analysis in the gamma (40-60Hz) and alpha (8-13Hz) bands.

* [3_get_VE_frontiers_PAC.m](https://github.com/neurofractal/PACmeg/blob/master/3_get_VE_frontiers_PAC.m) = this script computes a V1 virtual electrode, using the HCP-MMP-1.0 atlas. Other atlases could easy be used (e.g. the AAL atlas).

* [4_calc_pow_change.m](https://github.com/neurofractal/PACmeg/blob/master/4_calc_pow_change.m) = this script calculates the change in oscillatory power (1-100Hz) using the V1 virtual electrode.

* [5_visual_PAC_four_methods.m](https://github.com/neurofractal/PACmeg/blob/master/5_visual_PAC_four_methods.m) = this script uses 4 different methods to quantify alpha-gamma PAC. Non-parametric statistics are then applied to determine changes in PAC between baseline and grating periods.

* [6_check_non_sinusoidal.m](https://github.com/neurofractal/PACmeg/blob/master/6_check_non_sinusoidal.m) = this script checks the low-frequency phase for differences in non-sinusoidal oscillations.

* [7_simulated_PAC_analysis.m](https://github.com/neurofractal/PACmeg/blob/master/7_simulated_PAC_analysis.m) = this script simulates PAC, checks for the detection of this coupling using three approaches, and investigates how much data is needed for reliable PAC estimates.

## PAC Function

The calc_MI function can be used in isolation, for data arranged in a Fieldtrip structure: 

* **[calc_MI](https://github.com/neurofractal/PACmeg/blob/master/functions/calc_MI.m)**

Please note: This function is still under-development, but will be back-compatible with data presented within the manuscript.

```matlab

function [MI_matrix_raw,MI_matrix_surr] = calc_MI(virtsens,toi,phase,amp,diag,surrogates,approach)

% Inputs:
% - virtsens = MEG data (1 channel)
% - toi = times of interest in seconds e.g. [0.3 1.5]
% - phases of interest e.g. [4 22] currently increasing in 1Hz steps
% - amplitudes of interest e.g. [30 80] currently increasing in 2Hz steps
% - diag = 'yes' or 'no' to turn on or off diagrams during computation
% - surrogates = 'yes' or 'no' to turn on or off surrogates during computation
% - approach = 'tort','ozkurt','canolty','PLV'
% Optional Inputs:
% - Number of phase bins used in KL-MI-Tort approach (default = 18)
%
% Outputs:
% - MI_matrix_raw = phase amplitude comodulogram (no surrogates)
% - MI_matrix_surr = = phase amplitude comodulogram (with surrogates)
%
```

Currently the function only accepts data from a **single** channel which could be obtained using an atlas-based approach (e.g. AAL atlas or HCP-MMP 1.0).

The PAC algorithms from Tort et al., (2010), Ozkurt & Schnitzler (2011), Canolty et al., (2006) and Cohen (2008) are implemented, and more will be added soon.

Example use:

```matlab

% To produce a PAC comodulogram on a single channel using the 
% Tort et al., (2010) approach, 0.3-1.5s post-stimulus onset between
% 7-13Hz phase and 34-100Hz amplitude, normalised by surrogate data:

[MI_matrix] = calc_MI(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes','tort')

```

Please be aware of the various methodological pitfalls in PAC analysis before applying the scripts to your own data (see Seymour, Kessler & Rippon manuscript).

---

For more information/queries please raise an ISSUE within Github or email me: robbyseymour [at] gmail.com . I am also very keen for collaborations to help improve and expand this code.
