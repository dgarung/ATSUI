function x0 = step1_x0

%**************************************************************************
% step1_x0:  Initial decision variables in the 1st step, which is 
% equally distributed points throughout the source area at a specified
% spatial interval indicated in the 'source_area.txt'.
% -------------------------------------------------------------------------

%------Load parameters
param = getappdata(0,'PARAM');

sa = param.sa;
grid = param.grid;
ye = param.ye;
bathy = param.bathy;

%------Initially distributed unit sources with fixed interval 
intv = sa.intv;
[llat,llon] = degreelen(ye);% length based on latitude
dlon = intv/(llon/1000); 
dlat = intv/(llat/1000); 

[xu yu] = meshgrid(sa.wst:dlon:sa.est,sa.sth:dlat:sa.nth);
xu = reshape(xu,numel(xu),1);
yu = reshape(yu,numel(yu),1);

%------Find index of the unit source relative to the source area
iu = 1+round((xu-sa.wst)*(sa.m-1)/(sa.est-sa.wst));
ju = 1+round((yu-sa.sth)*(sa.n-1)/(sa.nth-sa.sth));
x0 = sub2ind([sa.n sa.m],ju,iu); % convert matrix coordinates to index 

%------Find water depth at unit sources
[du land] = find_depth(xu,yu,bathy,grid);
x0(land) = []; % remove points on the land 

return
