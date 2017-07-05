# sensory_PAC

MATLAB scripts for detecting and validating phase amplitude coupling (PAC) in electrophysiological data.

Written and maintained by [Robert Seymour](http://robertseymour.me), June 2017.

![Imgur](http://i.imgur.com/XkNWkZn.png)

## Please Note:

These scripts correspond to the manuscript:

**Seymour, Kessler & Rippon (2017). The Detection of Phase Amplitude Coupling During Sensory Processing. In prep.**

Please download the MEG and anatomical data from [Figshare](https://figshare.com/projects/The_Detection_of_Phase_Amplitude_Coupling_During_Sensory_Processing/22762).

Scripts can be easily adapted for your computer by modifying the sensory_PAC.m script:

```matlab
data_dir = 'path_to_data';
scripts_dir = 'path_to_scripts';
fieldtrip_dir = 'path_to_fieldtrip';
subject = {'sub-01','sub-02','sub-03','sub-04','sub-05','sub-06','sub-07',...
    'sub-08','sub-09','sub-10','sub-11','sub-12','sub-13','sub-14',...
    'sub-15','sub-16'};
```

## Analysis should be performed in the following order:

* [1_preprocessing_elektra_frontiers_PAC.m](https://github.com/neurofractal/sensory_PAC/blob/master/1_preprocessing_elektra_frontiers_PAC.m) = this script performs simple preprocessing steps and removes bad trials

* [2_get_source_power.m](https://github.com/neurofractal/sensory_PAC/blob/master/2_get_source_power.m) = this script performs source analysis in the gamma (40-60Hz) and alpha (8-13Hz) bands.

* [3_get_VE_frontiers_PAC.m](https://github.com/neurofractal/sensory_PAC/blob/master/3_get_VE_frontiers_PAC.m) = this script computes a V1 virtual electrode, using the HCP-MMP-1.0 atlas. Other atlases could easy be used (e.g. the AAL atlas).

* [4_calc_pow_change.m](https://github.com/neurofractal/sensory_PAC/blob/master/4_calc_pow_change.m) = this script calculates the change in oscillatory power (1-100Hz) using the V1 virtual electrode.

* [5_visual_PAC_four_methods.m](https://github.com/neurofractal/sensory_PAC/blob/master/5_visual_PAC_four_methods.m) = this script uses 4 different methods to quantify alpha-gamma PAC. Non-parametric statistics are then applied to determine changes in PAC between baseline and grating periods.

* [6_check_non_sinusoidal.m](https://github.com/neurofractal/sensory_PAC/blob/master/6_check_non_sinusoidal.m) = this script checks the low-frequency phase for differences in non-sinusoidal oscillations.

* [7_simulated_PAC_analysis.m](https://github.com/neurofractal/sensory_PAC/blob/master/7_simulated_PAC_analysis.m) = this script simulates PAC, checks for the detection of this coupling using three approaches, and investigates how much data is needed for reliable PAC estimates.

The following PAC functions can also be used in isolation, for data arranged in a Fieldtrip structure: 

* **[calc_MI](https://github.com/neurofractal/sensory_PAC/blob/master/calc_MI.m)**
* **[calc_MI_ozkurt](https://github.com/neurofractal/sensory_PAC/blob/master/calc_MI_ozkurt.m)**
* **[calc_MI_canolty](https://github.com/neurofractal/sensory_PAC/blob/master/calc_MI_canolty.m)**
* **[calc_MI_PLV](https://github.com/neurofractal/sensory_PAC/blob/master/calc_MI_PLV.m)**

Example use:

```matlab

% To produce a PAC comodulogram on a V1 virtual electrode using the 
% Tort et al., (2010) approach, 0.3-1.5s post-stimulus onset between
% 7-13Hz phase and 34-100Hz amplitude, normalised by surrogate data:

[MI_matrix] = calc_MI_tort(VE_V1,[0.3 1.5],[7 13],[34 100],'no','yes')

```

However, please be aware of the various methodological pitfalls in PAC analysis before applying the scripts to your own data (see Seymour, Kessler & Rippon manuscript).

---

For more information/queries please raise an ISSUE within Github or email me: robbyseymour [at] gmail.com
