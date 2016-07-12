FOR TERRESTRIAL MODEL:

Range calculations with only firing threshold:

daylightFiringThreshRange (saves values under daylight.mat)
moonlightFiringThreshRange (saves values under moonlight.mat)
starlightFiringThreshRange (saves values under starlight.mat)
uses Parameters

to limit the range with contrast threshold:

daylightContrastLimiting (saves values under actualDaylight.mat)
moonlightContrastLimiting (saves values under actualMoonlight.mat)
starlightContrastLimiting (saves values under actualStarlight.mat)
uses Parameters

calculate volume and derivates of terrestrial model:

terrestrialGetDerivatives (CONTRASTTHRESH variable controls which values are imported (1: actualDaylight/Moonlight/Starlight, 0: daylight/moonlight/starlight))
uses derivative
uses Parameters

plot:

plotTerrestrialRange
uses Parameters

calculation of smallest target size:

terrestrialSmallestTargtSize (if contrast threshold limit is not desired comment out line 66-line 86)
uses Parameters

calculation of contrast range relationship:

contrastRangeRelation (saves values under, constrastDaylight/Moonlight/Starlight, pupil diameter values are constant at 1mm, 8.3mm, 1.55cm, 3cm controlled by the pupilValues variable)
uses Parameters

interpolatePlotContrastRange (incomplete!, interpolate to Contrast 0, range 0 for all pupil values and plot the ranges) 


FOR AQUATIC MODEL:

range calculation with depth constant:

pupilSizevsRangeConstantDepth_Coastal (saves values under 
pupilSizevsRangeConstantDepth_River

(asks the user for a vector input of desired depths (PROMPT: 1), uses the vector [5 7 10] (PROMPT:0
)
uses derivative
uses Parameters

plot:

plotAquaticRange (there are problems with legend placement, once the plots were created I dragged the legend to the appropriate place) 
uses columnlegend
uses Parameters

TODO calculation of smallest target size:



