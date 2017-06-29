# sensory_PAC

Scripts for detecting and validating phase amplitude coupling (PAC) in electrophysiological data.

Written by [Robert Seymour](http://robertseymour.me), June 2017.

![Imgur](http://i.imgur.com/XkNWkZn.png)

## The scripts correspond to the manuscript:

**Seymour, Kessler & Rippon (2017). The Detection of Phase Amplitude Coupling During Sensory Processing. In prep.**

Please download the MEG and anatomical data from [Figshare](https://figshare.com/projects/The_Detection_of_Phase_Amplitude_Coupling_During_Sensory_Processing/22762).

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

However, please be aware of the various methodological pitfalls in PAC analysis before applying the scripts to your own data (see Seymour, Kessler & Rippon manuscript).

---

For more information/queries please raise an ISSUE within Github or email me: robbyseymour [at] gmail.com
