function stop = cache_step2(iter,fval,x)

global step2_x step2_fval

%Never stop from this function
stop = false;

k = 1;
if iter>=0
    k = iter+k;
    %Capturing the cache
    step2_x(k,:) = x;
    step2_fval(k,:) = fval;
end

end