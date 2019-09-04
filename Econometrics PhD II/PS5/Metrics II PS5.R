#############################################################################
# Program Name:   Metrics II PS5.R
# Location:       /Users/zongyangli/Documents/GitHub/econometrics-essential/Econometrics PhD II/PS2/Metrics II PS2.R
# Author:         
# Date Created:   
#############################################################################

source("/Users/zongyangli/Documents/Github/R-Key-functions/Start up.R")
setwd("/Users/zongyangli/Documents/GitHub/econometrics-essential/Econometrics PhD II/PS5")

########################################################################
## Q1: Bootstrap CI ##

# generate unform sample on [-1, 1]
sample <- runif(1000, min = -1, max = 1)
sample_mean = mean(sample) # -0.0089

# resample
B = 500 # num of draws
n = length(sample) # size of BS sample = original sample size
boot_sample <- matrix(sample(sample, size = B*n, replace = T), B, n)

# compute mean for bootstrap sample
boot_sample_mean = apply(boot_sample, 1, mean) # calculate mean for each row(draw)

# compute empirical theta_hat - theta_0 & quntiles
theta_star = boot_sample_mean - sample_mean
d = quantile(theta_star, c(0.05, 0.95))

# calculate the 90% CI
CI = sample_mean - c(d[2],d[1])
cat('Confidence interval: ',CI, '\n')


########################################################################
## Q1.2: Loop to check Bootstrap  ##

result <- data.frame(V1=integer(),V2=integer()) ## save the accuracy result
sample_size <- c(10,500)

j = 1 # j allow to change column in saving result
for(n in sample_size){
	for(i in 1:500) {
		# bootstrap as in Q1
		sample <- runif(n, min = -1, max = 1)
		sample_mean = mean(sample)
		boot_sample <- matrix(sample(sample, size = B*n, replace = T), B, n)
		boot_sample_mean = apply(boot_sample, 1, mean)
		theta_star = boot_sample_mean - sample_mean
		d = quantile(theta_star, c(0.05, 0.95))
		CI = sample_mean - c(d[2],d[1])
		# count the result: if the true mean (0) is contained in the CI, return 1
		result[i,j] = ifelse(CI[[1]] < 0 & 0 < CI[[2]], 1, 0)
	}
j = j + 1
}

# Calculate the accuracy rate for two different sample sizes
sum(result$V1)/500 # 0.85
sum(result$V2)/500 # 0.906


########################################################################
## Q2: Rademacher Distribution  ##

result_2 <- data.frame(V1=integer(),V2=integer()) ## save the accuracy result_2
sample_size <- c(10,500)

j = 1 # j allow to change column in saving result_2
for(n in sample_size){
	for(i in 1:500) {
		# generate Rademacher distribution & z_i
		sample_1 <- runif(n*B, min = -1, max = 1)
		sample_1[sample_1 >= 0] <- 1 
		sample_1[sample_1 <= 0] <- -1 
		sample_2 <- 2^(rgeom(n*B, prob = 0.5)/2) 
		sample_product = sample_1*sample_2
		sample_mean = mean(sample_product)	
		# resample
		boot_sample <- matrix(sample(sample_product, size = B*n, replace = T), B, n)
		boot_sample_mean = apply(boot_sample, 1, mean)
		theta_star = boot_sample_mean - sample_mean
		d = quantile(theta_star, c(0.05, 0.95))
		CI = sample_mean - c(d[2],d[1])
	# count the result_2: if the true mean (0) is contained in the CI, return 1
	result_2[i,j] = ifelse(CI[[1]] < 0 & 0 < CI[[2]], 1, 0)
	}
j = j + 1
}

# Calculate the accuracy rate for two different sample sizes
sum(result_2$V1)/500 # 0.85
sum(result_2$V2)/500 # 0.906






