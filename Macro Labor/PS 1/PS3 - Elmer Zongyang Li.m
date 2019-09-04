%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program Name:   PS3 - Elmer Zongyang Li.m
% Location:       /Users/zongyangli/Documents/Github/econometrics-essential/Macro Labor/PS 1/PS3 - Elmer Zongyang Li.m
% Author:         
% Date Created:   
% Project:        
% Input:          
% Output:         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Question 2
%%%%%

clear; clc; 
% parameters 
    c = 4.0; 
    mu = log(5.0); 
    sigma = 0.5; 

% set up functions
    % the integral
    g = @(w_hat) (integral(@(w_prime) ((w_prime - w_hat).*lognpdf(w_prime,mu,sigma)),w_hat,1000));
    fun = @(x) (x(2)/(1-x(2))*g(x(1)) + c - x(1)); 

% solve the functions
    x0 = [0,0]; 
    x = fsolve(fun,x0)





