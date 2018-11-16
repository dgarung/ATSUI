function stop = cache_step1(iter,fval,x)

global step1_x step1_fval

%Never stop from this function
stop = false;

k = 1;
if iter>=0
    k = iter+k;
    %Capturing the cache
    step1_x(k,:) = x;
    step1_fval(k,:) = fval;
end

end