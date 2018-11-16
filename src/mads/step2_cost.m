function fx = step2_cost(x,save)

%**************************************************************************
% step2_cost:  Cost function of the 2nd step.

% save = 1 : store the current result in terms of the slip distribution
% save = 0 or other : do not store the current result 
% -------------------------------------------------------------------------

%------Load parameters
param = getappdata(0,'PARAM');
fault = param.fault;
smooth = param.smooth;
dp = param.dp;
dp_loc = param.dp_loc;
sa = param.sa;
grid = param.grid;

%-------Generate subfault coordinates
[xsf ysf xsc ysc dz flt] = makesf_center(x);

%-------Okada's model to construct Green's function
[llat,llon] = degreelen(x(2));% length based on latitude
slp = 1; % Slip
opn = 0; % Open
for i = 1:flt
    E = (dp_loc(:,1)-xsf(i,1))*llon/1000;
    N = (dp_loc(:,2)-ysf(i,1))*llat/1000;
    
    [ue,un,uz] = okada85(E,N,dz(i),x(4),x(5),fault.Lsf,fault.Wsf,x(6),...
                 slp,opn);
    G(:,i) = uz;
end

%-------Smoothing
[laplacian_op val] = laplace_op(fault.Nns,fault.Nwe,flt);

lap = smooth*laplacian_op;
Gs = [G;lap];  % matrix of Green's functions and laplacian operator
ds = [dp;val];  % observation matrix and laplacian operator values
    
%-------Nonnegative least squares
inv_slp = lsqnonneg(Gs,ds);

%-------Calculate final displacement from the invetred slip
dsp = G*inv_slp;

%-------Compute error (sum of RMSE) as the cost function
SE   = (dsp-dp).^2;
RMSE = sqrt(mean(SE(:))) ; 
fx  = double(RMSE); 

%------Store current result in terms of inverted waveforms & displacements
if save==1
    %---Inverted slip
    result.slip = inv_slp;
    result.f_par = x;
    
    %---Seafloor displacement in the source area due to slip
    [llat,llon] = degreelen(x(2));% length based on latitude
    [lonu,latu] = meshgrid(sa.wst:grid.dx:sa.est,sa.sth:grid.dx:sa.nth);
    lonu = reshape(lonu,sa.m*sa.n,1);
    latu = reshape(latu,sa.m*sa.n,1);
    opn = 0;
    sfd = zeros(sa.n,sa.m);
    for i = 1:flt
        E = (lonu-xsf(i,1))*llon/1000;
        N = (latu-ysf(i,1))*llat/1000;

        [ue,un,uz] = okada85(E,N,dz(i),x(4),x(5),fault.Lsf,fault.Wsf,x(6),...
                     inv_slp(i),opn);
        uz = reshape(uz,sa.n,sa.m);
        sfd = sfd + uz;
    end
    result.sfd = sfd;

    %---Store subfault coordinate for plotting
    result.xsf = xsf;
    result.ysf = ysf;
    result.flt = flt; % total number of subfaults

    setappdata(0,'RESULT',result);
    
end

return
