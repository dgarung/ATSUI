function [laplacian_op val] = laplace_op(lsf,wsf,tsf)

% subfaults dimension 4 x 2
% length = 4 subfaults, width = 2 subfaults
% lsf = 6; % number of subfault along strike
% wsf = 2; % number of subfault down dip

d1(1:tsf) = -4;
%d2(1:tsf-1) = 1;

for i = 1:tsf-1
    if mod(i,lsf)~=0
        d2(i) = 1;
        d3(i) = 1;
    else
        d2(i) = 0;
        d3(i) = 0;
    end
end

d4(1:tsf-lsf) = 1;
d5(1:tsf-lsf) = 1;

diag1 = diag(d1);
diag2 = diag(d2,1);
diag3 = diag(d3,-1);

diag4 = diag(d4,lsf);
diag5 = diag(d5,-lsf);

laplacian_op = diag1+diag2+diag3+diag4+diag5;

val = zeros(length(laplacian_op),1);      % values are zero
