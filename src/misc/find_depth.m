function [du land] = find_depth(xu,yu,depth,grid)

%------Grid info
wst = grid.wst;
est = grid.est;
sth = grid.sth;
nth = grid.nth;

m = grid.m; n = grid.n; 

%------Find water depth at (xu,yu)
iu  = 1+round((xu-wst)*(m-1)/(est-wst));
ju  = 1+round((yu-sth)*(n-1)/(nth-sth));
idx = sub2ind([n m],ju,iu); % convert matrix coordinates to index
du  = depth(idx); % water depth
land = find(du<0); % on the land
du(land) = []; % remove point on the land 