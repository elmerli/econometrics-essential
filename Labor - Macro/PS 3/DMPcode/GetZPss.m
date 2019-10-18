function [err] = GetZPss(bb_in,gam_in,cc_in)
global alf sigm bet rr sep yrho ysig vfSS jfSS thetaSS ygrid yPP ynn

err= cc_in/vfSS - bet*((1-gam_in)*(1-bb_in)-gam_in*cc_in*thetaSS+(1-sep)*cc_in/vfSS);
