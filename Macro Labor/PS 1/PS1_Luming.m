 %=========================================================================
%  Luming CHEN
%  Department of Economics, Cornell University, lc929
%  Sep 1st, 2019
%  Macro Labor, PSet 1, Problem 2 and 3
%=========================================================================

clc
clear all

%% Problem 2

% 1. Parameters

c      = 4;
miu    = log(5.0);
sig    = 0.5;
B      = 1000;
beta   = 0.95;
delta  = 0.005;

% 2. Functions

difference = @(wr) (integral(@(w)((w - wr).*lognpdf(w,miu,sig)),wr,B) * beta/(1-beta) - wr + c);

% 3. Solve
sln_1  = fsolve(difference, 50);


%% Problem 3

% 1. Ingredients

w      = 0:delta:B;
N      = length(w);
p      = logncdf(w + delta/2,miu,sig) - logncdf(w - delta/2,miu,sig);
p(1)   = logncdf(w(1) + delta/2,miu,sig);
p(N)   = 1 - logncdf(w(N) - delta/2,miu,sig);
v0     = zeros(1,N);
tol    = 1e-8;
diff   = 1;
v_ac   = w/(1-beta);
v      = v0;      

% 2. Evaluation

while diff > tol
    v0    = v;
    v_rj  = (c + beta * sum(v0 .* p))*ones(1,N);
    v     = max(v_ac, v_rj);      
    diff  = sqrt(sum((v - v0) .^ 2));
    
end

sln_2  = v(1)*(1-beta);

% 3. Plot

figure; hold on
a1 = plot(w,v_ac); M1 = "$V_{Accept}$";
a2 = plot(w,v_rj); M2 = "$V_{Reject}$";
a3 = plot([sln_2 sln_2],get(gca,'ylim'),'--'); M3 = "Reservation Wage";
legend([a1,a2,a3], [M1, M2, M3],'Location','east','Interpreter','latex');
hold off
xlim([0 50])
ylim([0 1000])
title('Finding Reservation Wage')
xlabel('w') 
ylabel('v') 
