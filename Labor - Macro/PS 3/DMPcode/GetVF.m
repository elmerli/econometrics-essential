function [fval] = GetVF(theta)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS elas

fval = min( sigm.*theta.^(-alf), 1.0);
end
