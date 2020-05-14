function obj = X_GMM_obj2(theta, Cst)
beta=0.9;

% Unpack estimates

tuple=Cst.tuple;
g_bar=Cst.g_bar;
W=diag(Cst.obs);

% Fixed point iteration and solve for continuation value function v^c
gamma = theta0(1:2);
%sigma = theta(3);
sigma = 1;
    
% Calculate g_hat
v = Cst.Minv*sigma;
g_hat = exp(-(beta*v - tuple*gamma)./sigma);

% Calculate weighted moment   

m = g_hat- g_bar;

obj = m'*W*m;

end
