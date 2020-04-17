function y = homo_decon(DATA, lf, s)


l = size(DATA, 1);
if l == 1
    DATA = DATA';
end

Df = ifft(log(abs(fft(DATA))));

if (s == 'w')
    Df(lf:1:end) = 0;
else
    Df(1:1:lf) = 0;
end

Df = 2*Df;

y = real(ifft(exp(fft(Df))));

return