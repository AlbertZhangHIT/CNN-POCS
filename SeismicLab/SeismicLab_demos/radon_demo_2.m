%RADON_DEMO_2: Multiple removal with the Parabolic Radon Transform
%
%
%        -------------------------------------------
%           A demo showing how one can eliminate
%              multiples using the Parabolic 
%                     Radon Transform 
%                    (real data demo)
%
%                 M.D.Sacchi, SeismicLab
%        -------------------------------------------
%
%
% Parabolic Radon demultiple is used to estimate the primaries.
% D = Prim + Mult, an estimate of the primaries is obtained by
% modelling the multiples with the parabolic Radon transform:
% Estimate of Prim = D - Modelled Multiples
%
% This demo uses the following SeismicLab functions:
%
%               readsegy.m
%               pradon_demultiple.m
%               clip.m
%               seismic.m

  clear;
  close all;


% Read data - a nmo-ed corrected marine gather
% from the Gulf of Mexico

  [D,H] = readsegy('gom_cdp_nmo.su');
  

% We will use a subset of the data

  D = D(800:1200,:);

% Extract areas that were muted

  Mutes = ones(size(D)); 
  I = find(D==0); 
  Mutes(I)=0;

% Extract offet and sampling interval

  h = [H.offset];
  dt = H(1).dt/1000/1000;

% Define parameters for Radon Demultiple

  qmin = -0.3;
  qmax = .8;
  nq = 120;
  flow = 2.;
  fhigh = 90;
  mu = 0.1;
  q_cut = 0.05;


  [P,M,tau,q] = pradon_demultiple(D,dt,h,qmin,qmax,nq,flow,fhigh,mu,q_cut);

% Apply data mutes back to estimate of primaries

  P = P.*Mutes;


% Display results

  subplot(131); pimage(h,tau,clip(D,50,50));
  xlabel('Offset [ft]');
  ylabel('Time [s]');

  subplot(132); pimage(q,tau,clip(M,50,50));
  xlabel('Residual moveout [s]');

  subplot(133); pimage(h,tau,clip(P,50,50));
  xlabel('Offset [ft]');

  colormap(seismic(1));
