function [S,tau,v] = velan(d,dt,h,vmin,vmax,nv,R,L);
%VELAN: A program to compute velocity spectra.
% 
%  [S,tau,v] = velan(d,dt,h,vmin,vmav,nv,R,L);
%
%  IN   data:      data
%       dt:        sampling interval in secs
%       h:         vector of offsets in meters
%       vmin:      min velocity to scan
%       vmax:      max velocity to scan
%       nv:        number of velocities
%       R:         integer (2,3,4) indicating that the samblance 
%                  is computed every R time samples 
%       L:         the lenght of the gate of analysis is 2L+1
%
%  OUT  S:         Measure of energy - in this case unnormalized 
%                  cross-correlation in the gate
%       v,tau:     axis vectors to plot the semblance using, for instance, 
%                  imagesc(v,tau,S)
%
%  Reference: Yilmaz, 1987, Seismic Data Processing, SEG Publication
%
%  Example: see va_demo.m
%
%
%  Copyright (C) 2008, Signal Analysis and Imaging Group
%  For more information: http://www-geo.phys.ualberta.ca/saig/SeismicLab
%  Author: M.D.Sacchi
%
%  This program is free software: you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation, either version 3 of the License, or
%  any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details: http://www.gnu.org/licenses/
%



  [nt, nh] = size(d);

  v = linspace(vmin,vmax,nv);

  nv = length(v);
  tau = (0:R:nt-1)*dt;
  ntau = length(tau);
  taper = hamming(2*L+1);
  H = hamming(2*L+1)*ones(nh,1)';

  for it = 1:ntau
  for iv = 1:nv  

  time = sqrt( tau(it)^2 + (h/v(iv)).^2 );

  s = zeros(2*L+1,nh);

  for ig = -L:L;
  ts = time + (ig-1)*dt;

  for ih = 1:nh

   is = ts(ih)/dt+1;
   i1 = floor(is);
   i2 = i1 + 1;

  if i1>=1 & i2<=nt ;
   a = is-i1;
   s(ig+L+1,ih) = (1.-a)*d(i1,ih) + a*d(i2,ih);   %Grab sample with Linear interpolation
  end;

  end
  end

   s = s.*H;
   s1  = sum( (sum(s,2)).^2);
   s2  = sum( sum(s.^2));
   S(it,iv) = abs(s1-s2);

  end
  end

 S = S/max(max(S));

 return;
    
