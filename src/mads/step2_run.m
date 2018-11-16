function result = step2_run

%**************************************************************************
% step2_run:  Optimization settings and plots.
% -------------------------------------------------------------------------

%------ Make dir for outputs
out = 'outputs/optimization';
if ~exist(out,'dir')
     mkdir(out);
end

%------Set parameters
step2_param;

%------Initial condition
x0 = step2_x0;

%------Test the initial distribution
step2_cost(x0,1);
init = getappdata(0,'RESULT');

%------Define global variables
global step2_x step2_fval; %to save decision variables & cost func values

%------Dimension of decision variables
dim = size(x0,1); % number of decision variables (unit sources)

%------Objective function
fx = @(x)step2_cost(x,0);

%------Bounds
param = getappdata(0,'PARAM');
lb = param.lb;
ub = param.ub;
lb = [lb.lon;lb.lat;lb.depth;lb.strike;lb.dip;lb.rake]; 
ub = [ub.lon;ub.lat;ub.depth;ub.strike;ub.dip;ub.rake]; 

%------Real decision variables
xtype = ['CCCCCC']; % see OPTI manual for detail

%------Options for OPTI toolbox 
opts = optiset('display','iter','solver','nomad','iterfun',...
               @cache_step2,'maxfeval',50000);
           
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
for i = 1:size(step2_fval,1)
    if step2_fval(i)<tmp
        j = j+1; 
        tmp = step2_fval(i);
        s_fval(j) = step2_fval(i);
        s_x{j} = step2_x(i,:);
    end
end
save([out,'/step2_fval.mat'],'s_fval'); % cost func values 
save([out,'/step2_x.mat'],'s_x'); % unit source index  

%------Test the optimization result
step2_cost(x,1);
result = getappdata(0,'RESULT');
opt_slip = result.slip; % slip distribution
opt_fpar = result.f_par; % fault parameters
opt_sfd = result.sfd; % seafloor displacement due to slip

%------Stored optimized slip distribution
%------create file for gmt plotting
fid=fopen([out,'/opt_slip.txt'],'w');
for i=1:size(opt_slip,1)
    fprintf(fid,['> -Z',num2str(opt_slip(i)),'\n']);
    fprintf(fid,'%12.8f %12.8f\n',...
    [result.xsf(i,1), result.ysf(i,1);result.xsf(i,2), result.ysf(i,2);...
     result.xsf(i,3), result.ysf(i,3);result.xsf(i,4), result.ysf(i,4);...
     result.xsf(i,1), result.ysf(i,1)]');
end
fclose(fid);

%------Stored optimized seafloor displacement for plotting (in grd format)
sa = param.sa;
grid = param.grid;
xs  = sa.wst:grid.dx:sa.est;
ys  = sa.sth:grid.dx:sa.nth;
grdwrite2(xs,ys,opt_sfd,[out,'/opt_sfd.grd']);

%------Stored optimized fault parameters
fid=fopen([out,'/opt_fpar.txt'],'w');
fprintf(fid,'%6s %6s %8s %9s %6s %6s\n','lon','lat','depth','strike','dip','rake');
fprintf(fid,'%6.4f %6.4f %6.2f %6.2f %6.2f %6.2f',opt_fpar);
fclose(fid);

%------Plot slip distribution and the corresponding seafloor displacement
plot_slip_sfd(init,result)

return


function [] = plot_slip_sfd(init,result)
%------Load param
param = getappdata(0,'PARAM');
sa = param.sa;
grid = param.grid;
xs  = sa.wst:grid.dx:sa.est;
ys  = sa.sth:grid.dx:sa.nth;

figure,
subplot(1,2,1),hold on
hold on
for i = 1:init.flt
    h1 = patch(init.xsf(i,:),init.ysf(i,:),init.slip(i));
end
c = colorbar('southoutside');
c.Label.String = 'Slip (m)';
colormap(flipud(hot));
hc = contour(xs,ys,init.sfd,'-','color',[0.6 0.6 0.6]);
title('Initial'),axis equal image

subplot(1,2,2),hold on
hold on
for i = 1:result.flt
    h1 = patch(result.xsf(i,:),result.ysf(i,:),result.slip(i));
end
c = colorbar('southoutside');
c.Label.String = 'Slip (m)';
colormap(flipud(hot));
hc = contour(xs,ys,result.sfd,'-','color',[0.6 0.6 0.6]);
title('Optimized'),axis equal image

return

