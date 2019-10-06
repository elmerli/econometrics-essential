function [y_sim,w_sim,u_sim,v_sim,th_sim]=simul(y,P,n_y,c_ss,b,gamma,alpha,delta,q_theta_ss,sigma_m,theta,n_sim);
y_sim(1)= y(1);
th_sim(1)=theta(1);
w_sim(1)= gamma*y_sim(1) + (1-gamma)*b + c_ss*gamma*th_sim(1);
u_sim(1)= delta/(delta+q_theta_ss);
v_sim(1)=th_sim(1)*u_sim(1);
%v_sim(1)=1-u_sim(1);


i=1;

for t = 2:n_sim
    u_sim(t) = (1-u_sim(t-1))*delta + (1-min(sigma_m*th_sim(t-1)^(1-alpha),1))*u_sim(t-1);
%    i=ceil(n_y*rand);
    j = 1;
    check=rand;
    P_temp = P(i,j);
    while (P_temp < check)
        j = j + 1;
        P_temp = P_temp + P(i,j);
    end
   i = j;
    y_sim(t) = y(i);
    th_sim(t) = theta(i);
    w_sim(t) = gamma*y_sim(t) + (1-gamma)*b - c_ss*gamma*th_sim(t);
    %v_sim(t) = 1-u_sim(t);  
    v_sim(t) = th_sim(t)*u_sim(t);
end
