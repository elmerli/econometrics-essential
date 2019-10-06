clear;
%clc;


% Declare parameters - would be outcome of calibration

glob.beta      = 0.970;
%glob.beta      = 0.980;
glob.ro        = 0.9923;
glob.se        = 0.0983;
glob.gamma     = 1.0;
glob.alf       = 0.36;
glob.depr      = 0.025;
glob.bel_print = 0;
glob.slower    = 0;
glob.r         = 0.04-glob.depr;
glob.sol = 'egm';
glob.tfp       = 1.00;

% Find equilibrium r
[rx,glob_out0] = GetEquilR(glob)

glob.tfp = 1.10;
[rx,glob_out] = GetEquilR(glob)
