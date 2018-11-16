function param = step1_param

%**************************************************************************
% step1_param:  Storage of global data for the optimization problem.
% -------------------------------------------------------------------------

%------Bathymetry
[lon,lat,bathy] = grdread2('bathy.grd');
grid.wst = min(lon); grid.est = max(lon);
grid.sth = min(lat); grid.nth = max(lat);
grid.m = length(lon);
grid.n = length(lat);
grid.dx = lon(2)-lon(1); % calculate grid size from bathymetry data (dx=dy)

%------Parameters for reciprocity corrections
load st_radius; % Gaussian radius at each stations relative to epicenter (Rs)

%------Synthetics waveforms
load syn 

%------Observed waveforms & time interval  
obs = load('observation.txt');

%------Time window for inversion (in minute) 
tw = load('t_window.txt');
twin = [tw(:,1) tw(:,2)];

%------Epicenter info
ep = load('epicenter.txt');
xe = ep(1); ye = ep(2); Re = ep(3); 
de = find_depth(xe,ye,bathy,grid); % depth at epicentre

%------Source area
source_area = textscan(fopen('source_area.txt'), '%f %*[^\n]');
sa.wst = source_area{1}(1); % West boundary
sa.est = source_area{1}(2); % East boundary
sa.sth = source_area{1}(3); % South boundary
sa.nth = source_area{1}(4); % North boundary
sa.intv = source_area{1}(5); % Spatial interval of initial unit sources
sa.m = 1+round( (sa.est - sa.wst)/grid.dx ); % Number of grids inside source area (xdir)
sa.n = 1+round( (sa.nth - sa.sth)/grid.dx ); % Number of grids inside source area (ydir)

%------Construct observation vector (d) for inversion, and (d2) for
%testing, which is observed waveforms outside inversion period 
[d d2] = construct_ov(obs,twin);
ov.d = d;
ov.d2 = d2;

%*******************************************************************************
param.bathy = bathy;
param.Rs = Rs;
param.syn = syn;
param.obs = obs;
param.twin = twin;
param.Re = Re;
param.de = de;
param.sa = sa;
param.grid = grid;
param.ov = ov;
param.ye = ye;

setappdata(0,'PARAM',param);

return
