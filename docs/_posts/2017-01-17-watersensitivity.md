---
layout: post
title: Effect of different water models on visual range
tags: [compviz, visual-range, hydrolight, matlab]
---

Given that the actual intrinsic water properties and organic matter concentrations are not known for Late Devonian, we generated results for clear, absorption dominated, high turbidity and scattering dominated water types with details given in Supplementary Appendix Table S3. These have attenuation lengths of 1.17 m (clear), a high absorption water model at 0.52 m, a high turbidity model at 0.31 m, and a high scattering model at 0.22 m (quoted at 575 nm, the wavelength of highest transparency for the Baseline River water model used as our reference case).

The folder [aquatic_model](https://github.com/maciverlab/bigeye/tree/master/figs/figExt06_sensitivity/aquatic_model) contains the functions to calculate visual range based on both the firing and contrast threshold. *Aquatic_firingThreshSensitivity.m* calculates visual range based on firing threshold and saves it to the data file titled *meteoAquaticSensitivity.mat*, which contains both the pupil values used and a visual ranges (1st dimension across pupil diameters, 2nd dimension across water models and 3rd dimension across viewing directions). On the other hand, *Aquatic_contrastThreshSensitivity.m* loads the data file *meteoAquaticSensitivity.mat* and decreases range until the object is visible, which is dependent on the apparent contrast of the object and observer’s contrast threshold. These new ranges saved into a data file named *visibilityAquaticSensitivity.mat* while preserving the data structure. 

An example run of these two functions look like:

```Matlab
run Aquatic_firingThreshSensitivity
run Aquatic_contrastThreshSensitivity
```

These data files are then used to generate the main figure. The figure function can be found in [figures](https://github.com/maciverlab/bigeye/tree/master/figs/figExt06_sensitivity/figures) folder. Function titled *figExt06_sensitivity.m* takes in the optional boolean argument *CONTRASTTHRESH*, where the default value is set to be true. If specified as true, visual ranges based on contrast threshold will be plotted, and if false, visual ranges based on firing threshold will be displayed. Before creating the figure, the program searches for all of the required data files. If it any of them are missing the corresponding function is executed. If however all of the data files exist, the program asks the user if they want to re-generate the data. 


The figure function is executed by typing:

```Matlab
run figExt06_sensitivity
```

The output of this function is a two panel figure that depicts visual ranges based on different water models for upward and horizontal viewing.

![Visual range due to different water models]({{ site.url }}/assets/figExt06.png)
