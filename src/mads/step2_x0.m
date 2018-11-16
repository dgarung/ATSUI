function x0 = step2_x0

%**************************************************************************
% step2_x0:  Initial decision variables in the 2nd step, which are
% fault parameters, such as fault center location, depth, strike, dip, and
% rake.
% -------------------------------------------------------------------------

%------Load parameters
param = getappdata(0,'PARAM');
fault = param.fault;

x0 = [fault.lon;fault.lat;fault.depth;fault.strike;...
      fault.dip;fault.rake];

return
