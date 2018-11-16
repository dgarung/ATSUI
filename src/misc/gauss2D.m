function [z] = gauss2D(amp,x,y,R,dx,dy,grid);
% The code is for generating superposition of Gaussian unit sources

%------Grid info
wst = grid.wst;
est = grid.est;
sth = grid.sth;
nth = grid.nth;

m = grid.m; n = grid.n; 

%------Matrix/local coordinate
ic  = 1+round((x-wst)*(m-1)/(est-wst));
jc  = 1+round((y-sth)*(n-1)/(nth-sth));
[xgrid, ygrid] = meshgrid(1:m,1:n);

z = zeros(n,m);
for i = 1:length(amp)
    sigma_x = R(i)/dx; 
    sigma_y = R(i)/dy; 
    xc = ( (xgrid-ic(i))./ (sigma_x/2) ).^2;
    yc = ( (ygrid-jc(i))./ (sigma_y/2) ).^2;
    z = amp(i)*exp(-(xc+yc))+z; % Superposition
end



