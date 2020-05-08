%% Subprogram whose output is to be minimized
function wtd_moments = wtd_moms(theta,phi_i,phi_j,...
    sigma_i_hat_t,sigma_j_hat_t,num_a_i,num_a_j,...
    num_s_i,num_s_j,T,num_betas,data_array,y_t)
% form sigma_hat for country Red
for s_i_index=1:num_s_i
    for s_j_index=1:num_s_j % for each state s
        sigma_i_hat_denom = exp(phi_i(:,1,s_i_index,s_j_index)'*theta)+...
            exp(phi_i(:,2,s_i_index,s_j_index)'*theta)+...
            exp(phi_i(:,3,s_i_index,s_j_index)'*theta);
        % following formula for MNL, since errors assumed extreme value
        for i_index=1:num_a_i
                sigma_i_hat(i_index,s_i_index,s_j_index)= ...
                    exp(phi_i(:,i_index,s_i_index,s_j_index)'*theta)...
                    /sigma_i_hat_denom;    
        end
    end
end
% form sigma_hat for country White
for s_i_index=1:num_s_i
    for s_j_index=1:num_s_j % for each state s
        sigma_j_hat_denom = exp(phi_j(:,1,s_i_index,s_j_index)'*theta)+...
            exp(phi_j(:,2,s_i_index,s_j_index)'*theta)+...
            exp(phi_j(:,3,s_i_index,s_j_index)'*theta);
        % following formula for MNL, since errors assumed extreme value
        for j_index=1:num_a_j
                sigma_j_hat(j_index,s_i_index,s_j_index)= ...
                  exp(phi_j(:,j_index,s_i_index,s_j_index)'*theta)...
                  /sigma_j_hat_denom;    
        end
    end
end

% form sigma_hat_t for the states realized in the data
for t=1:T
    s_i_index = data_array(t,3)+1;
    s_j_index = data_array(t,4)+1;
    sigma_i_hat_t(:,t) = sigma_i_hat(:,s_i_index,s_j_index);
    sigma_j_hat_t(:,t) = sigma_j_hat(:,s_i_index,s_j_index);   
end
sigma_hat_t=[sigma_i_hat_t; sigma_j_hat_t];
% form sample moment condition to calculate wtd_moments
A_n = eye(num_betas); % the weighting matrix here is the identity matrix
dif = y_t-sigma_hat_t;
%for t=1:T
%dif(2,t)=dif(2,t)*data_array(t,3); % error terms time with state variables
%dif(5,t)=dif(5,t)*data_array(t,4); % error terms time with state variables
%end
sample_moms = mean(dif,2); % sample moment conditions
% weighted moments to be minimized
wtd_moments = sample_moms'*A_n*sample_moms; 

%%