function [d d2] = construct_ov(obs,twin)
% obs   : observed waveforms at observation stations
% twin  : time window for inversion

t  = obs(:,1); % time(in min) 
obs = obs(:,2:end); % observed tsunami waveforms
ns = size(obs,2); % number of observation stations

%------Construct observation array (d)
for i = 1:ns
    idt{i} = find(t>=twin(i,1) & t<=twin(i,2));% inside inversion period
    idt2{i} = find(t<twin(i,1) | t>twin(i,2));% outside inversion period
    d{i} = obs(idt{i},i);
    d2{i} = obs(idt2{i},i);
end

%------Combine cells array
d = cat(1,d{:});  % observation array
d2 = cat(1,d2{:});  % observation array
