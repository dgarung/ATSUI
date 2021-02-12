function param = step2_param

%**************************************************************************
% step2_param:  Storage of global data for the optimization problem.
% -------------------------------------------------------------------------

%------Load fixed fault & quadtree parameters 
fixed_par = textscan(fopen('fixed_par.txt'),'%f %*[^\n]');

%------Load fault parameters & bounds for the optimization
opt_par = textscan(fopen('opt_par.txt'),'%f %f %f %*[^\n]');

%------Bathymetry
[lon,lat,bathy] = grdread2('bathy.grd');
grid.wst = min(lon); grid.est = max(lon);
grid.sth = min(lat); grid.nth = max(lat);
grid.m = length(lon);
grid.n = length(lat);
grid.dx = lon(2)-lon(1); % calculate grid size from bathymetry data (dx=dy)

%------Inverted displacement by the 1st step 
load opt_ssd;

%------Quadtree decomposition to obtain the data points
th = fixed_par{1}(5);
minseg = fixed_par{1}(6);
maxseg = fixed_par{1}(7);
[dp idp rect] = quadtreeseg(opt_ssd,th,[minseg minseg],[maxseg maxseg]);
id = find(rect>size(opt_ssd,1)-1); % remove points beyond source area
%[irem jrem] = ind2sub(size(rect),id);
%rect(irem,:) = []; % matrix coordinate of each generated-rectangle
%dp(irem) = []; % data points (equivalent to the obs. vector) used for the inversion 
%idp(irem) = []; % index of the data points based on number of grids inside the source area

%------Source area
source_area = textscan(fopen('source_area.txt'),'%f %*[^\n]');
sa.wst = source_area{1}(1); % West boundary
sa.est = source_area{1}(2); % East boundary
sa.sth = source_area{1}(3); % South boundary
sa.nth = source_area{1}(4); % North boundary
sa.m = 1+round( (sa.est - sa.wst)/grid.dx ); % Number of grids inside source area (xdir)
sa.n = 1+round( (sa.nth - sa.sth)/grid.dx ); % Number of grids inside source area (ydir)

%------Selected points based on the quadtree decomposition
%[dlon,dlat] = meshgrid(sa.wst:grid.dx:sa.est,sa.sth:grid.dx:sa.nth);
[dlon,dlat] = meshgrid(linspace(sa.wst,sa.est,sa.m),linspace(sa.sth,sa.nth,sa.n));
dlon = dlon(idp);
dlat = dlat(idp);
dp_loc = [dlon dlat]; % coordinate of points resulted by the quadtree

%------Fault parameters
%---Fixed paramaters
fault.L = fixed_par{1}(1);
fault.W = fixed_par{1}(2);
fault.Lsf = fixed_par{1}(3);
fault.Wsf = fixed_par{1}(4);
fault.Nns = round(fault.L/fault.Lsf); % Number of faults along strike 
fault.Nwe = round(fault.W/fault.Wsf); % Number of faults along dip
%---Optimized paramaters / decision variables
fault.lon = opt_par{1}(1);
fault.lat = opt_par{1}(2);
fault.depth = opt_par{1}(3);
fault.strike = opt_par{1}(4);
fault.dip = opt_par{1}(5);
fault.rake = opt_par{1}(6);

%------Smoothing parameters
smooth = fixed_par{1}(8);

%------Optimization lower bounds
lb.lon = fault.lon - opt_par{2}(1);
lb.lat = fault.lat - opt_par{2}(2);
lb.depth = fault.depth - opt_par{2}(3);
lb.strike = fault.strike - opt_par{2}(4);
lb.dip = fault.dip - opt_par{2}(5);
lb.rake = fault.rake - opt_par{2}(6);

%------Optimization upper bounds
ub.lon = fault.lon + opt_par{2}(1);
ub.lat = fault.lat + opt_par{2}(2);
ub.depth = fault.depth + opt_par{2}(3);
ub.strike = fault.strike + opt_par{2}(4);
ub.dip = fault.dip + opt_par{2}(5);
ub.rake = fault.rake + opt_par{2}(6);

%*******************************************************************************
param.fault = fault;
param.smooth = smooth;
param.dp = dp;
param.dp_loc = dp_loc;
param.sa = sa;
param.grid = grid;
param.lb = lb;
param.ub = ub;

setappdata(0,'PARAM',param);

return
