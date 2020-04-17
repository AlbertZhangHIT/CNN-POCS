function y = sparseThresh(x, dx, dt, lambda, mode, threshmode)
if strcmp(mode, 'curvelet')
    
end
if strcmp(mode, 'fourier')
    fx = fft2(x)*dx*dt;
    fx = wthresh(fx, threshmode, lambda);
    y = real(ifft2(fx/dx/dt));
end

end