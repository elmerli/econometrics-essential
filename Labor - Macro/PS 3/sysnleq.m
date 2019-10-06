function th_res = sysnleq(theta,y,P,b,gamma,alpha,sigma_m,beta,delta,c,n_y)
F_temp = zeros(1,n_y);
theta=real(theta);
for i = 1:n_y
    for j = 1:n_y
        w = gamma*y(j) + (1-gamma)*b + c*gamma*theta(j);
        F_temp(i) = F_temp(i) + beta*P(i,j)*(y(j) - w + (1-delta)*c/min(sigma_m*theta(j)^-alpha,1));
    end
    F(i) = c/min(sigma_m*theta(i)^-alpha,1)-F_temp(i);
end
%th_res=F;
th_res = F + theta - sqrt(F.^2 + theta.^2);