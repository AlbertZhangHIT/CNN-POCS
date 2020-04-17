%SPITZ_DEMO: Example showing Spitz FX interpolation
%
%        -----------------------------------
%         A demo for Spitz FX interpolation
%
%            M.Naghizadeh and M.D.Sacchi
%                    SeismicLab
%        -----------------------------------
% 
% Spitz FX interpolation is designed for interpolating
% events with linear moveout. It can tolarate, however,
% curvature as shown in this example. In general,
% the method should be applied in small overlapping
% windows.
%
% This demo uses the following SeismicLab functions:
%
%               readsegy.m 
%               spitz_fx_interpolation.m
%               wigb.m
%

clear;
close all;

% Read a file (su format)

  [d,H] = readsegy('gom_cdp_nmo.su');

% Extract offet and sampling interval 

  h = [H.offset];
  dt = H(1).dt/1000/1000;

% Use a subset of the data

  n0 = 700;
  d = d(n0:1100,:);

% Time axis for figures

  [nt,nh] = size(d);
  t0 = (n0-1)*dt;
  taxis = t0+[0:1:nt-1]*dt;
  
% New offset coordinates after interpolation

  h_interp = linspace(max(h),min(h),2*nh-1);

% Parameters for interpolation

  npf = 10;            % Length of the pef
  pre1 = 1;            % percentage of pre-whitening for estimating the pef
  pre2 = 1;            % percentage of pre-whitening for estimating the data
  flow = 0.1;          % first frequency for the f-x process (Hz)
  fhigh = 90;          % last frequncy (Hz)

  [d_interp] = spitz_fx_interpolation(d,dt,npf,pre1,pre2,flow,fhigh);

% Figures - first with wiggles

  figure(1);
  subplot(121); wigb(d,2,h,taxis); title('Original');
  subplot(122); wigb(d_interp,2,h_interp,taxis); title('After Spitz FX Interpolation');

% Figures - images

  figure(2);
  subplot(121); imagesc(h,taxis,clip(d,60,60)); title('Original');
  subplot(122); imagesc(h_interp,taxis,clip(d_interp,60,60)); title('After Spitz FX Interpolation');
  colormap(seismic);
 

  
