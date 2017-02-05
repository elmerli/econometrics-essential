library(readxl)
klein_data<-read_excel("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS1/klein_data.xls", sheet = "klein_data")

# Set new variables

klein_data$wpg = klein_data$Wp*klein_data$G
klein_data$Pl = c(NA,klein_data$P[-length(klein_data)]) # length is the last one, -1 is the first one
klein_datal = klein_data[-1,]


install.packages("gmm")
library(gmm)
library(sandwich)
attach(klein_datal) # aviods doing $ all the time

# Run the gmm model

gmm1 = gmm(C ~ P + Pl + wpg, ~ I + K + GNP + Wg)
summary(gmm1)
  # library gmm r - google
# mid-term:        J-test   P-value
# Test E(g)=0:    1.07773  0.29921
# this tests if the moment conditions hold

# Calculate estimated variance of coefficients
  # var1 = (gmm1$residuals)*length(gmm1$residuals)/length(gmm1$residuals) - length(gmm1$coefficients) # n/n-k * residuals
var1 = gmm1$vcov

# Calculate estimated variance of residuals
var_res = t(gmm1$residuals)%*%gmm1$residuals/(length(gmm1$residuals)-length(gmm1$coefficients)) # %*% is multiple of matrix


#### Q5

data1<-read_excel("/Users/elmerleezy/Google Drive/Wagner/Semester 4/Applied Stats & Econo II/Prob Sets/PS1/FormattedData.xlsx", sheet = "Sheet3")

# using gcnq gcsq to infor the consumption -> sum them

data1$C.ret = rowSums(data1[c('gcnq','gcsq')])/c(NA,rowSums(data1[c('gcnq','gcsq')]))[-dim(data1)[1]]
test.assets = c('govb','corp','tbill','vwr','ewr')
BBeta = 1
mtx = as.matrix(data1[-1,c(test.assets,'C.ret')])

g = function(gam,mtx){
  1 - BBeta (1+mtx[,c(1,length(test.assets))])*mtx[,length(test.assets)+1]^-gam
}

# keep in mind that people say that normal values of risk-aversion parameter btw 2-8







