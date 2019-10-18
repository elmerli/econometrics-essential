function [stats]  = GetStats(theta,bb_in,gam_in,cc_in,flag)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ygrid yPP ynn ...
  burnin nsim zsims

if nargin==4
  % Simulate: set parameters
  ypath = zeros(burnin+nsim,1);
  upath = zeros(burnin+nsim+1,1);
  wpath = zeros(burnin+nsim,1);
  tpath = zeros(burnin+nsim,1);
  
  wgrid  = (1-gam_in)*bb_in.*ones(ynn,1) + gam_in*(cc_in*theta + ygrid);
  jfgrid = GetJF(theta);
  
  upath(1) = sep/(jfSS+sep);
  
  for it=1:burnin+nsim
    yy=zsims(it);
    tpath(it) = theta(yy);
    ypath(it) = ygrid(yy);
    wpath(it) = wgrid(yy);
    [upath(it+1)] = (1-upath(it))*sep + (1-jfgrid(yy))*upath(it);
  end
  %
  vpath = tpath.*upath(1:end-1);
  %
  ypath = mean(reshape(ypath(burnin+1:end),[13, nsim/13]),1);
  upath = mean(reshape(upath(burnin+2:end),[13, nsim/13]),1);
  wpath = mean(reshape(wpath(burnin+1:end),[13, nsim/13]),1);
  tpath = mean(reshape(tpath(burnin+1:end),[13, nsim/13]),1);
  vpath = mean(reshape(vpath(burnin+1:end),[13, nsim/13]),1);
  
  stats.umean = mean(upath);
  stats.jfmean = mean(jfgrid);
  [ty cy]=hpfilter(log(ypath),1600);
  [tu cu]=hpfilter(log(upath),1600);
  [tq cq]=hpfilter(log(tpath),1600);
  [tw cw]=hpfilter(log(wpath),1600);
  [tv cv]=hpfilter(log(vpath),1600);
  %
  stats.sigu = std(cu);
  stats.sigy = std(cy);
  stats.sigt = std(cq);
  stats.sigw = std(cw);
  stats.sigv = std(cv);
  %
  filler = autocorr(cu,1);
  stats.rhou = filler(2);
  %
  filler = autocorr(cy,1);
  stats.rhoy = filler(2);
  %
  filler = autocorr(cq,1);
  stats.rhot = filler(2);
  %
  filler = autocorr(cw,1);
  stats.rhow = filler(2);
  %
  filler = autocorr(cv,1);
  stats.rhov = filler(2);
  %
  stats.corrmat = corr([cu, cv, cq, cy]);
  %
  stats.elast = corr(cw,cy)*stats.sigw/stats.sigy;
  stats.wshare = mean(wpath)/mean(ypath);

else

  
  wgrid  = (1-gam_in)*bb_in.*ones(ynn,1) + gam_in*(cc_in*theta + ygrid);
  
  ypath = ygrid(zsims(burnin+1:end));
  wpath = wgrid(zsims(burnin+1:end));

%  ypath = zeros(nsim,1);
%  wpath = zeros(nsim,1);
%  for it=burnin+1:burnin+nsim
%    yy=zsims(it);
%    ypath(it-burnin) = ygrid(yy);
%    wpath(it-burnin) = wgrid(yy);
%  end
% CH: no gain to vectorization

  %
  ypath = mean(reshape(ypath,[13, nsim/13]),1);
  wpath = mean(reshape(wpath,[13, nsim/13]),1);
  
  [ty cy]=hpfilter(log(ypath),1600);
  [tw cw]=hpfilter(log(wpath),1600);
  %
  stats.elast = regress(cw,cy);
  stats.wshare = mean(wpath)/mean(ypath);
end
