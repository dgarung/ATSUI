function result = step1_run

%**************************************************************************
% step1_run:  Optimization settings and plots.
% -------------------------------------------------------------------------

%------ Make dir for outputs
out = 'outputs/optimization';
if ~exist(out,'dir')
     mkdir(out);
end

%------Set parameters
step1_param;

%------Initial condition
x0 = step1_x0;

%------Test the initial distribution
step1_cost(x0,1);
init = getappdata(0,'RESULT');

%------Define global variables
global step1_x step1_fval %to save decision variables & cost func values

%------Dimension of decision variables
dim = size(x0,1); % number of decision variables (unit sources)
param = getappdata(0,'PARAM');
sa = param.sa;
mid = sa.m*sa.n; % Upper bounds = total number of grids inside source area 

%------Objective function
fx = @(x)step1_cost(x,0);

%------Bounds
lb = ones(dim,1); % minimum number or points inside the source area
ub = mid*ones(dim,1); % maximum number or points inside the source area 

%------Integer decision variables
xtype = repmat('I',1,dim);

%------Options for OPTI toolbox 
opts = optiset('display','iter','solver','nomad','iterfun',...
               @cache_step1,'maxfeval',50000);
           
%------Create OPTI Object
Opt = opti('fun',fx,...
           'bounds',lb,ub,...
           'xtype',xtype,...
           'options',opts);

%------Solve the specified problem
[x,fval,exitflag,info] = solve(Opt,x0); 

%------Modify cache to only output fval reduction & save optimization history
tmp = inf;
j = 0;
for i = 1:size(step1_fval,1)
    if step1_fval(i)<tmp
        j = j+1; 
        tmp = step1_fval(i);
        s_fval(j) = step1_fval(i);
        s_x{j} = unique(step1_x(i,:));
    end
end
save([out,'/step1_fval.mat'],'s_fval'); % cost func values 
save([out,'/step1_x.mat'],'s_x'); % unit source index  

clear cache_x cache_fval

%------Test the optimization result
step1_cost(x,1);
result = getappdata(0,'RESULT');
opt_ssd = result.ssd; % sea surface displacement
opt_us = result.us_location; % unit source locations
opt_wf = result.waveform; % waveforms

%------Stored optimized sea surface displacement in the 'outputs' for 
% further processing or plotting (in grd format)
grid = param.grid;
xs  = sa.wst:grid.dx:sa.est;
ys  = sa.sth:grid.dx:sa.nth;
grdwrite2(xs,ys,opt_ssd,[out,'/opt_ssd.grd']);

%------Stored optimized inverted waveforms in the 'outputs' (in txt format)
obs = param.obs;
t = obs(:,1);
dlmwrite([out,'/opt_ssd_wf.txt'],[t opt_wf],'delimiter','\t')

%------Stored optimized sea surface displacement in the 'inputs' for the
% 2nd step inversion
save(['inputs/opt_ssd.mat'], 'opt_ssd');

%------Plot sea surface displacement
plot_ssd(init,result)

%------Plot waveforms
plot_wf(init,result)

return


function [] = plot_ssd(init,result)
%------Load param
param = getappdata(0,'PARAM');
sa = param.sa;
grid = param.grid;
xs  = sa.wst:grid.dx:sa.est;
ys  = sa.sth:grid.dx:sa.nth;

figure,
subplot(1,2,1),hold on
pcolor(xs,ys,init.ssd),shading flat
plot(init.us_location(:,1),init.us_location(:,2),'ro','markersize',2)
title('Initial'),axis equal image
subplot(1,2,2), hold on
pcolor(xs,ys,result.ssd),shading flat
plot(result.us_location(:,1),result.us_location(:,2),'ro','markersize',2)
title('Optimized'),axis equal image

return

function [] = plot_wf(init,result)
%------Load param
param = getappdata(0,'PARAM');
obs = param.obs;
t = obs(:,1);
obs = obs(:,2:end);

figure,
for i = 1:size(obs,2)
    subplot(3,3,i),hold on
    plot(t,obs(:,i),'color',[0.6 0.6 0.6],'linewidth',1.2)
    plot(t,init.waveform(:,i),'linewidth',1.0)    
    plot(t,result.waveform(:,i),'linewidth',1.0)
    if i==size(obs,2)
        hl = legend('Observation','Initial','Optimized');
        set(hl,'orientation','horizontal')
        pos = get(hl,'position');
        set(hl,'position',[pos(1) pos(2)-0.24 pos(3) pos(4)])
    end
end

return