function [fval] = GetJF(theta)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ynn

fval = min( sigm.*theta.^(1-alf), ones(size(theta,1),1) );
end
