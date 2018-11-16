function [Xp Yp xSc ySc dz flt] = makesf_center(x)

X0  = x(1); % Longitude of fault origin
Y0  = x(2); % Latitude of fault origin
dep = x(3); % Depth  (in km)
str = x(4); % Strike
dip = x(5); % Dip

param = getappdata(0,'PARAM');
fault = param.fault;
Nns = fault.Nns; % Number of faults along strike 
Nwe = fault.Nwe; % Number of faults along dip
Lsfault = fault.Lsf; %Subfault length (in km) 
Wsfault = fault.Wsf; %Subfault width (in km) 

%--calculation of the total L and W of the initial fault area 
Lsfp=Lsfault*Nns;
Wsfp=Wsfault*cosd(dip)*Nwe;

%--Find location ptB(XA,YA) from pt0(X0,Y0)
ang = atand((Wsfp/2) / (Lsfp/2));
len = sqrt( (Wsfp/2)^2 + (Lsfp/2)^2 );
[XA YA]=findlonlat(X0,Y0,str+180+ang,len);
%--Find location ptB(XB,YB) from ptA(XA,YA)
[XB YB]=findlonlat(XA,YA,str,Lsfp);
%--Find location ptC(XC,YC) from ptB(XB,YB)
[XC YC]=findlonlat(XB,YB,str+90,Wsfp);
%--Find location ptD(XD,YD) from ptA(XA,YA)
[XD YD]=findlonlat(XA,YA,str+90,Wsfp);

%--Compute lon lat of vertices
[xSf ySf lat lon xSc ySc] = calc_coords(XA,YA,XB,YB,XC,YC,XD,YD,Nns,Nwe);

flt = 0; % final number of fault after removal
for j = 1:Nwe
    for i = 1:Nns
        flt = flt+1;
        Xp(flt,:) = [lon(j,i) lon(j,i+1) lon(j+1,i+1) lon(j+1,i)];
        Yp(flt,:) = [lat(j,i) lat(j,i+1) lat(j+1,i+1) lat(j+1,i)];
    end
end

%------Top edge of subfaults
dz = dep;
dz = dz*ones(1,Nns) ; % 
a  = ones(1,Nwe)*Wsfault;
b  = a*sind(dip);
for i=2:Nwe
    dz(i,:) = dz(i-1,:)+b(i);
end
dz = reshape(dz',1,Nwe*Nns);

end

function [xSf ySf lat lon xSc ySc]=...
    calc_coords(XA,YA,XB,YB,XC,YC,XD,YD,Nns,Nwe)

% point X --> relative to fault
%             upper --> shallowest
%             lower --> deppest
% A-----------B
% |           |
% |           |
% D-----------C
% point A --> upper left corner
% point B --> upper right corner
% point C --> lower right corner
% point D --> lower left corner

xB=zeros(1,Nwe+1);
yB=zeros(1,Nwe+1);
xD=zeros(1,Nwe+1);
yD=zeros(1,Nwe+1);

for i = 1:Nwe+1
    xB(i) = XB + ((XC-XB)/Nwe*(i-1));
    yB(i) = YB + ((YC-YB)/Nwe*(i-1));
    
    xD(i) = XA + ((XD-XA)/Nwe*(i-1));
    yD(i) = YA + ((YD-YA)/Nwe*(i-1));
    
    xDc(i) = xD(i) + ((XD-XA)/(Nwe*2));
    yDc(i) = yD(i) + ((YD-YA)/(Nwe*2));
end

% for j = 1:Nns+1
%     xC(j) = XD + ((XC-XD)/Nns*(j-1));
%     yC(j) = YD + ((YC-YD)/Nns*(j-1));
% end

for m = 1:Nwe
    for n = 1:Nns
        nk = n+((m-1)*(Nns));
        xSf(nk) = xD(m) + ((xB(m)-xD(m))/Nns*(n-1));
        ySf(nk) = yD(m) + ((yB(m)-yD(m))/Nns*(n-1));
        
        xSC(m)  = xDc(m) + ((xB(m)-xD(m))/(Nns*2));
        ySC(m)  = yDc(m) + ((yB(m)-yD(m))/(Nns*2));
        xSc(nk) = xSC(m) + ((xB(m)-xD(m))/Nns*(n-1));
        ySc(nk) = ySC(m) + ((yB(m)-yD(m))/Nns*(n-1));
    end
end


for m = 1:Nwe+1
    for n = 1:Nns+1
        nk = n+((m-1)*(Nns+1));
        xSf2(nk) = xD(m) + ((xB(m)-xD(m))/Nns*(n-1));
        ySf2(nk) = yD(m) + ((yB(m)-yD(m))/Nns*(n-1));
        
% Matrix coordinate
        lon(m,n)=xSf2(nk);
        lat(m,n)=ySf2(nk);
    end
end

end


function [lon lat]=findlonlat(lon1,lat1,tc,dist)

% FINDLATLON finds latitude and longitude 
% from given course and distance form a known point
% lon1 : longitude of the known location (decimal degree)
% lat1 : latitude of the known location (decimal degree)
% tc : true course clock wise from north (degree)
% dist : distance (km)
% RADIANS.M and DEGREE.M functions are used

% by Aditya Gusman
% Hokkaido University 
% Nov-2010
% formulas are from http://williams.best.vwh.net/avform.htm

lat1rad=radians(lat1);
lon1rad=radians(lon1);
tcrad=radians(tc);
d=(dist/1.852)*pi/(180*60);

% Compute lat/lon
latrad=asin(sin(lat1rad).*cos(d)+cos(lat1rad).*sin(d).*cos(tcrad));
k=length(latrad);
for i=1:k
    if (latrad(i)<10^-10 && latrad(i)>-10^-10)
        latrad(i)=0;
    end
end


if (cos(latrad)==0)
    lonrad=lon1rad; % end point a pole
else
    dlonrad=asin(sin(tcrad).*sin(d)./cos(latrad));
    lonrad=mod(dlonrad+lon1rad,2*pi);
end

lat=degree(latrad);
lon=degree(lonrad);

function [rad]=radians(deg)

% RADIANS convert degree to radians

rad = deg *pi / 180;

end

function [deg]=degree(rad)

% DEGREE converts radians to degree

deg = rad * 180 / pi;
end

end

