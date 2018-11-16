%   This code computes Gaussian sources based on the reciprocity principle
%
%   Description:
%      The code calls a few functions stored in the 'src/misc'. 
%
%      There are three inputs required: 
%      1. 'inputs/stations.txt': Station locations.
%      2. 'inputs/bathy.grd': Bathymetry.
%      3. 'inputs/epicenter.txt': Epicenter location & predefined Gaussian
%         radius at the epicenter.
%
%      The outputs are:
%      1. Gaussian unit sources/water surface displacement at station 
%         locations. For instance,
%         at station 1 --> 'outputs/source/source_st1.grd'.    
%      2. Gaussian radius at each station 
%         (stored in 'outputs/source/st_radius.mat') used to calculate the 
%         reciprocal waveforms. The file is also stored in the 'inputs'
%         folder for the optimization stage.
%
% Iyan E. Mulia (Earthquake Research Institute, the University of Tokyo)
% 06/2018 
% iyan[at]eri.u-tokyo.ac.jp
%
%%
clear all; clc;
addpath('src/misc'); % Load required tools
addpath('inputs'); % Input files
%------ Make dir for outputs
out = 'outputs/source';
if ~exist(out,'dir')
     mkdir(out);
end

%------Observation station locations 
st = load('stations.txt');
nst = size(st,1); % number of stations

%------Bathymetry 
[lon,lat,bathy] = grdread2('bathy.grd');
%---Grid info
grid.m = length(lon); grid.n = length(lat);
grid.wst = min(lon); grid.est = max(lon);
grid.sth = min(lat); grid.nth = max(lat);

%------Epicenter location & intial Gaussian radius 
% The radius used here is based on the ATSUI paper, which is 40 km
ep = load('epicenter.txt');
xe = ep(1); ye = ep(2); Re = ep(3); 

%------Additional parameters  
g  = 9.81; % gravity
am = 1; % initial amplitude 
[llat,llon] = degreelen(ye);% length based on latitude
dx = llon*(grid.est-grid.wst)/grid.m; % forward model grid size in x-dir (m)
dy = llat*(grid.nth-grid.sth)/grid.n; % forward model grid size in y-dir (m)

%-------Find depth at epicenter 
de = find_depth(xe,ye,bathy,grid);

for i = 1:nst
%-------Calculate radius at each station relative to the epicenter
    ds(i) = find_depth(st(i,1),st(i,2),bathy,grid); % depth at i-th station
    Rs(i) = Re*sqrt(g*ds(i))/sqrt(g*de); % normalized by depth at epicenter 
  
%-------Gaussian source at stations
    dsp = gauss2D(am,st(i,1),st(i,2),Rs(i),dx,dy,grid);
    grdwrite2(lon,lat,dsp,[out,'/source_st',num2str(i),'.grd']);
end

%-------Save the radii for generating the reciprocal waveforms
Rs = Rs';
save([out,'/st_radius'],'Rs') 
save(['inputs/st_radius'],'Rs') % used as input for the optimization 

























