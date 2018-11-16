%   This code computes optimizations for the two-step inversion of the
%   ATSUI method using the MADS algorithm available in the OPTI toolbox.
%
%   Description:
%      The code calls functions stored in the 'src/misc'.
%      'src/mads' folder contains functions for MADS optimization
%      settings that work only with the OPTI toolbox:
%      https://github.com/jonathancurrie/OPTI 
%
%      Inputs for the 1st step are: 
%      1. 'inputs/bathy.grd': Bathymetry.
%      2. 'inputs/st_radius.mat': Gaussian radius at each stations computed
%         earlier by the 'run_source.m' 
%         (copied from 'outputs/source/st_radius.mat').
%      3. 'inputs/syn.mat': Snapshots of tsunami elevations in the 
%         predefined source area originating from the Gaussian sources at 
%         station locations. The 'syn.mat' is a cell array, where each cell
%         represents the station and contains NS x NG. NS is the number of
%         snapshots,and NG is the number of grids inside the source area.
%      4. 'inputs/observations.txt': Observed tsunami waveforms (1st column 
%         indicates time in minute). As an example, here we use artificial
%         observations.
%      5. 'inputs/t_window.txt': Inversion time windows for each station.
%      6. 'inputs/epicenter.txt': Epicenter location & predefined Gaussian 
%          radius at the epicenter.
%      7. 'inputs/source_area.txt': Source area & interval of the intial 
%         unit source distribution.
%
%      Outputs of the 1st step are: 
%      1. Evolution of decision variables & cost function at every 
%         iteration (stored in 'outputs/optimization/step1_x.grd' & 
%         'outputs/optimization/step1_fval.grd').    
%      2. 'results1' structure comprised of inverted waveforms (waveform),
%         sea surface displacement (ssd), and unit source locations 
%         (us_location).
%      3. The optimized sea surface displacement inside the source area
%         is stored in 'outputs/optimization/opt_ssd.grd', and the inverted
%         waveforms in 'outputs/optimization/opt_ssd_wf.txt'
%      3. The optimized sea surface displacement throughout the source 
%         area is also stored in 'inputs/opt_ssd.mat', which will later 
%         be used as one of the inputs in the 2nd step inversion
%         (slip inversion).
%
%      Inputs for the 2nd step are: 
%      1. 'inputs/fixed_par.txt': Fixed fault, quadtree decomposition, and 
%         smoothing parameters.
%      2. 'inputs/opt_par.txt': Fault parameters that are considered as 
%         decision variables including the bounds for the optimization.
%      3. 'inputs/bathy.grd': Bathymetry.
%      4. 'inputs/opt_ssd.mat': Inverted displacement by the 1st step 
%      5. 'inputs/source_area.txt': Source area (the interval of the 
%         intial unit source distribution is no longer required here).
% 
%      Outputs of the 2nd step are: 
%      1. Evolution of decision variables & cost function at every 
%         iteration (stored in 'outputs/optimization/step2_x.grd' & 
%         'outputs/optimization/step2_fval.grd').   
%      2. 'results2' structure comprised of slip distribution (slip),
%         optimized fault parameters (fpar), seafloor displacement due to
%         slip (sfd), subfault coordinates (xsf & ysf), and number of 
%         subfaults (flt). 
%      3. The resulted slip distribution (opt_slip.grd), optimized fault 
%         parameters (opt_slip.txt), and seafloor displacement (opt_sfd.grd)
%         are stored in the'outputs/optimization'.
% 
% Iyan E. Mulia (Earthquake Research Institute, the University of Tokyo)
% 06/2018 
% iyan[at]eri.u-tokyo.ac.jp
% 
% Acknowledgments: 
% 1. Okada's model function by Francois Beauducel.
% 2. L-curve criterion functions by Per Christian Hansen. 
% 3. Subfaults generation function by Aditya R. Gusman.
% 4. I/O function by by Paul Wessel and Walter H. F. Smith.
% 5. Quadtree decomposition function by Ahmad Humayun.

%%
clear all; clc;
addpath('src/mads'); % Path for MADS parameters & settings
addpath('src/misc'); % Path for other required functions 
addpath('inputs'); % Input files

%----- Start the 1st step (sea surface displacement inversion)
result1 = step1_run;

ask = input('Continue the optimization for the slip inversion?, Y/N [Y]:','s');
if ask=='N'
    return
end

%----- Start the 2nd step (slip inversion)
result2 = step2_run;



