function [M] = seismic(iop);
%SEISMIC: Colormap for seismic images
%
%  seismic(iop);
%
%  IN   iop:   1 = min is brown, zero is white, max is black
%              2 = min is red,   zero is white, max is black
%              3 = min is blue,  zero is white, max is red
%              Default is iop = 1
% 
%  OUT  M:     Colormap array 
%
%  Example:
%
%    [D,H]=readsegy('gom_cdp_nmo.su'); D = D(800:1100,:);
%    figure(1); imagesc(clip(D,80,80)); colormap(seismic(1));
%    figure(2); imagesc(clip(D,80,80)); colormap(seismic(2));
%    figure(3); imagesc(clip(D,80,80)); colormap(seismic(3));
%
%  Note: colormap(seismic) with no argument produces iop = 1
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



 if nargin==0; iop=1; end;; 

 N = 40;
 L = 40;

 if (iop == 1);

  u1 = [0.5*ones(1,N),linspace(0.5,1,128-N),linspace(1,0,128-N),zeros(1,N) ];
  u2 = [0.25*ones(1,N),linspace(0.25,1,128-N),linspace(1,0,128-N),zeros(1,N)];
  u3 = [zeros(1,N),linspace(0.,1,128-N),linspace(1,0,128-N),zeros(1,N)];

 end;

 if (iop == 2);

  u1 = [ones(1,N),linspace(1.,1,128-N),linspace(1,0,128-N),zeros(1,N)];
  u2 = [zeros(1,N),linspace(0.,1,128-N),linspace(1,0,128-N),zeros(1,N)];
  u3 = [zeros(1,N),linspace(0.,1,128-N),linspace(1,0,128-N),zeros(1,N)];

 end;

 if (iop == 3);

 u1 = [zeros(1,N),linspace(0.,1,128-N-L/2),ones(1,L),linspace(1,0.5,128-L/2)];
 u2 = [zeros(1,N),linspace(0.,1,128-N-L/2),ones(1,L),linspace(1,0.,128-N-L/2),zeros(1,N)];
 u3 = [linspace(0.5,1,128-L/2),ones(1,L),linspace(1,0.,128-N-L/2),zeros(1,N)];

end;

 M = [u1',u2',u3'];

 return;

