function fx = step1_cost(x,save)

%**************************************************************************
% step1_cost:  Cost function of the 1st step.

% save = 1 : store the current result in terms of inverted waveforms & 
%            displacement   
% save = 0 or other : do not store the current result 
% -------------------------------------------------------------------------

idx = unique(x); % selected point source locations

%------Load parameters
param = getappdata(0,'PARAM');

ov = param.ov;
ye = param.ye;
sa = param.sa;

%------Construct tsunami Green's function based on the reciprocity principle
%Waveforms inside time window (G or the Green's function)
%Waveforms outside time window (G2)
%Waveforms at the whole period for testing purpose (syn_c)
[G G2 syn_c xu yu Ru] = construct_gf(idx);

%------Observation vectors
d = ov.d;
d2 = ov.d2;

%% Tsunami waveform inversion
%------Damping constraint using L-curve criterion
[U,s,V] = csvd(G');
[corner,rho,eta] = l_curve(U,s,d);

%------Tikhonov regularization
lambda = corner;
I = eye(size(G,1),size(G,1)); 
w = pinv(G*G'+lambda*I)*(G*d);

%------Apply the weights to the initial synthetics
%--Inside inversion period
wf1 = G'*w; % inverted waveforms

%--Outside inversion period
wf2 = G2'*w; % inverted waveforms

%------Compute error (sum of RMSE) as the cost function
% RMSE1 is the error inside the inversion period, and the RMSE2 is the
% error outside the inversion period to avoid overfitting
RMSE1 = double( sum( sqrt(mean((d-wf1).^2)) ) ); 
RMSE2 = double( sum( sqrt(mean((d2-wf2).^2)) ) ); 
W = 1.25; % weight to emphasize on the invesion period accuracy

fx = W*RMSE1+RMSE2 ;

%------Store current result in terms of inverted waveforms & displacements
if save==1
    %---Waveforms for the whole period
    Ga = cat(1,syn_c{:})'; 
    wf = Ga'*w; % inverted waveforms
    nt = size(syn_c{1,1},1);% number of data points on waveforms
    ns = size(syn_c,2);% number of stations 
    wf = reshape(wf,nt,ns);
    result.waveform = wf;

    %---Sea surface displacements in the source area
    [llat,llon] = degreelen(ye);% length based on latitude
    dx = llon*(sa.est-sa.wst)/sa.m; % forward model grid size in x-dir (m)
    dy = llat*(sa.nth-sa.sth)/sa.n; % forward model grid size in y-dir (m)
    zu = gauss2D(w,xu,yu,Ru,dx,dy,sa);
    result.ssd = zu;
    
    %---Unit source locations
    loc = [xu yu];
    result.us_location = loc;

    setappdata(0,'RESULT',result);
end


return
