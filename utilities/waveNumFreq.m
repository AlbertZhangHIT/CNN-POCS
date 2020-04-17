function [wavenumber, k, f] = waveNumFreq(data, dx, dt)
%%% function y = waveNumFreq(data, dx, dy)
%%% Compute the wavenumber and frequency map of data
%%% INPUT
%%%    data:    input data
%%%    dx:      space interval in x-axis
%%%    dt:      time interval in t-axis
%%% OUTPUT
%%%    wavenumber:  wavenumber-frequency map of input data
%%%    k:         range of wavenumber
%%%    f:         range of frequency

[nt, nx] = size(data);
x = 0 : dx : (nx-1)*dx;
t = 0 : dt : (nt-1)*dt;

Nyqk = 1/(2*dx);
Nyqf = 1/(2*dt);
dk = 1/(nx*dx);
df = 1/(nt*dt);

k = -Nyqk : dk : Nyqk-dk;
f = -Nyqf : df : Nyqf-df;

wavenumber = fftshift(fft2(data))*dx*dt;


end