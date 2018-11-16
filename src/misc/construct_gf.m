function [G G2 syn_c xu yu Ru] = construct_gf(idx)

% idx   : index of points inside the source area (decision variables)

%------Load parameters
param = getappdata(0,'PARAM');

bathy = param.bathy;
Rs = param.Rs;
syn = param.syn;
obs = param.obs;
twin = param.twin;
Re = param.Re;
de = param.de;
sa = param.sa;
grid = param.grid;

%------Find points inside source area
[ju,iu] = ind2sub([sa.n sa.m],idx); % convert index to matrix coordinates 
%------Longitude & latitude 
xu = sa.wst+(iu-1)*(sa.est-sa.wst)/(sa.m-1); 
yu = sa.sth+(ju-1)*(sa.nth-sa.sth)/(sa.n-1);

%------Find water depth at the points
[du land] = find_depth(xu,yu,bathy,grid);

%------Remove points on the land 
xu(land)  = []; 
yu(land)  = []; 
idx(land) = []; 

g  = 9.81; % gravity
ns = size(syn,2); % number of observation stations 
t  = obs(:,1); % time (in min) 
%------Construct Green's function (G)
for i = 1:ns
    idt{i} = find(t>=twin(i,1) & t<=twin(i,2)); % inside inversion period
    idt2{i} = find(t<twin(i,1) | t>twin(i,2)); % outside inversion period
    %----Correct the synthetics based on the reciprocity approach
    Ru = Re*sqrt(g.*du)./sqrt(g*de); % radius at unit sources 
    cr = Ru.^2./Rs(i)^2; % correction factors for amplitudes
    cr = repmat(cr',size(syn{1,1},1),1);
    syn_c{1,i} = cr.*syn{1,i}(:,idx);
    G{i} = syn_c{1,i}(idt{i},:); % inside inversion period
    G2{i} = syn_c{1,i}(idt2{i},:); % outside inversion period
end

%------Combine cells array
G = cat(1,G{:})'; % Green's function
G2 = cat(1,G2{:})'; % synthetics waveforms outside inversion period 