function value = loglike(theta, data, type)

% specify parameters
    [N, ~] = size(data); 
    Nu = sum(data(:,2)>0); % num of unemployed - use >0 to count #
    Ne = N - Nu; % num of employed
    wage = data(data(:,1)>0,1); % the wages of the employed
    rwage = min(wage); % empirical minimum of the wages


% set up the distribution

if type == "logn"
        % solution parameters
        mu = theta(1); 
        sigma = theta(2); 
        lambda = theta(3); 
        delta = theta(4); 
        % cdf & pdf
        F_bar = 1 - logncdf(rwage, mu, sigma); 
        f_w = lognpdf(data(data(:,1) > 0,1), mu, sigma);  % data(data(:1) > 0,1) to select the values greater than 0
    elseif type == "exp"
        % solution parameters
        alpha = theta(1); 
        lambda = theta(2); 
        delta = theta(3);
        % cdf & pdf
        F_bar = exp(-alpha*rwage); 
        f_w = alpha*exp(-alpha*data(data(:,1) > 0,1)); 
end

% calculate the log-likelihood
value = N*log(lambda) + Nu*log(F_bar) ...
        - lambda*F_bar*sum(data(:,2)) + Nu*log(delta) ... % here use sum(..) without >0 to just sum the values
        + sum(log(f_w)) - N*log(delta + lambda*F_bar);

% because fmincon will minimize and we want to maximize, here turn into negative
value = - value;
end









