function obj= X_GMM_obj(theta, Cst, data, xx, sr, sw, w) 
%   AEM 7500  PS #4 sub-program 2
%   This program/function is the obj funtion of the GMM which is called by 
%   the estimation function to compute the value of the obj function given
%   the value of the parameters.
N_ar= Cst.N_ar;
N_aw= Cst.N_aw;
a_r= Cst.a_r;
a_w= Cst.a_w;
T= Cst.T;

% theta(1): beta0
% theta(2): beta1r
% theta(3): beta2
% theta(4): beta3r
% theta(5): beta1w
% theta(6): beta3w
beta=[theta(1) theta(2) theta(3) theta(4) theta(1) theta(5) theta(3) theta(6)]';
zz= xx*beta;
tid= kron((1:length(zz)/N_ar)', ones(N_ar,1)); 
denom= accumarray(tid, exp(zz));
prob= exp(zz)./denom(tid);
prob_r= prob(1:T*3);
prob_w= prob(T*3+1:end);
sigma_r= reshape(prob_r, 3, T);
sigma_w= reshape(prob_w, 3, T);
sigma_hat=[sigma_r(1:2,:)' sigma_w(1:2,:)' sigma_r(1:2,:)'.*sr sigma_w(1:2,:)'.*sw];

y_r = ( ones(N_ar,1)*data(:,1)'==a_r'*ones(1,T) );
y_w = ( ones(N_aw,1)*data(:,2)'==a_w'*ones(1,T) );
y = [y_r(1:2,:)' y_w(1:2,:)' y_r(1:2,:)'.*sr y_w(1:2,:)'.*sw];

%% Part III: Form the moment condition
m = mean( y - sigma_hat, 1);
obj = m*w*m';

%% Part IV: Form efficient weighting matrix
% g= y - sigma_hat;
% w= inv((g- mean(g))'*(g- mean(g)));
