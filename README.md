# sensory_PAC

Scripts for detecting and validating phase amplitude coupling (PAC) in electrophysiological data

![Imgur](http://i.imgur.com/XkNWkZn.png)

## Seymour, Kessler & Rippon (2017). The Detection of Phase Amplitude Coupling During Sensory Processing. In prep.

Please download the MEG data from [insert link to Figshare when available].

## Analysis should be performed in the following order:

* 1_preprocessing_elektra_frontiers_PAC.m = preprocessing the MEG data
* 2_get_source_power.m = perform source analysis
* 3_get_VE_frontiers_PAC.m = get V1 virtual electrode data
* 4_calc_pow_change.m = calculate the power change within area V1
* 5_visual_PAC_3_methods.m = calculate PAC using 4 different methods & perform stats
* 6_check_non_sinusoidal.m = check the low-frequency phase for non-sinusoidal oscillations
* 7_simulated_PAC_analysis.m = make simulated PAC, check for correct detection, vary data length

The various PAC scripts can also be used in isolation (for data arranged in a Fieldtrip structure): 

* calc_MI
* calc_MI_ozkurt
* calc_MI_canolty
* calc_MI_PLV

For more information/queries please raise an ISSUE within Github or email me: robbyseymour [at] gmail.com
