function c_res = evalcss(b,gamma,c,beta,delta,theta_ss,q_theta_ss)
y_ss=1;
w_ss = gamma*y_ss + (1-gamma)*b + c*gamma*theta_ss;
temp=(y_ss - w_ss + (1-delta)*(c/q_theta_ss));
c_res= c/q_theta_ss - beta*temp;