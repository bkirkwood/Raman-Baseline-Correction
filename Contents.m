%% Contents.m
%
% Baseline Fit Toolbox
% Version 1.0 (20220629)
% Code and Contents modified and posted 2022 Nov 14 by William Kirkwood - MBARI
% Copyright (C) 2022 by MBARI
% Script graphic point function modificaiton by Edward T Peltzer - MBARI
%
% Baseline fit script:  BLcorr_bfit1.m 
%
% BLcorr_bfit1.m is a modification of Bfit1.m  -  Original version of "baseline fit" written by Mirko Hrovat 08/01/2009
%% located at https://www.mathworks.com/matlabcentral/fileexchange/24916-baseline-fit?s_tid=srchtitle
%
%       Script file was revised to display manually selected baseline points as red circles on the
%         preview plot of the Raman spectrum. If fitted baseline is not acceptable, user is given
%         the option to re-display the preview plot and try again. Points are not limited and do 
%         not have to be equally spaced.
%
%       User is given the option to select upper and lower intensity limits on the preview plot in
%         order to better select the baseline points from an "intensity amplified" spectrum plot.
%
%       M-file to load 1 LRS data file and correct for fluorescence in the baseline by using the
%        "Bfit" function to manually select and subtract the "broad" Raman shift fluorescence bands.
%
%        - Data file must be in ascii format only with extn = asc.
%        - User can select standard (200-4500 cm-1) or custom Raman shift range.
%        - Output figure format = PORTRAIT.
%        - Output data file format = ascii.
%
%      M-file to load 1 LRS data file and correct for fluorescence in the baseline by using the
%        "Bfit" function to manually select and subtract the "broad" Raman shift fluorescence bands.
%
%        - Data file must be in ascii format only with extn = asc.
%        - User can select standard (200-4500 cm-1) or custom Raman shift range.
%        - Output figure format = PORTRAIT.
%        - Output data file format = ascii.
%
% Data Files for testing:
%
%   Abalone.asc
%   Cyclohexane.asc
%   Neon1.asc
%
%   It will take some practice to get a "feel" for the spline tool and the
%   resulting baceline correction. aexamples are include and explained
%   below.
%
%   Abalone_BaselinePLot.fig : this plot shows a major noise spike at about
%   2250 wave numbers. This is due to the Raman setup we used. Because our
%   system doubles back on itself in the CCD to get 200 to 4500 wave numbers 
%   contoinuously, a single spectra. The result is a discontinuity in the 
%   raw data. Stitching the spectra together to remove this would result in 
%   a cleaner looking plot but our practice is to not interpolate the count
%   intensity to make the baseline correction cleaner in that small section. 
%
%   Abalone_WindowedPLot.fig : this plot shows a windowed look at the spectra
%   from 200 to 2220 wave numbers removing the discontinuity to demonstrate
%   the performance of the baseline correction. 
%

