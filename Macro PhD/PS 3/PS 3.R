setwd("/users/isaacncohen/Desktop/Cornell/Fall 2018/Macroeconomics")
require(tidyverse)
require(reshape)

# parameters
delta <- 0.75
alpha <- 0.3
beta <- 0.6
f <- function(k) {return(k^alpha+(1-delta)*k)}

# stored values
K <- seq(from=0.01,to=0.25,by=0.0025)
v0 <- tibble(K,V0=0)
g0 <- tibble(K)

t <- 0
tolflag <- 10^(-6)
tol <- 1

# iterate value fx 
# while (tol > tolflag) {
  # temp policy/value fx's
  gtemp <- tibble(K,kp=NA)
  vtemp <- tibble(K,V=NA)
  # last value fx
  vL <- v0[,c(1,t+2)]
  # iterate over k
  for (i in 1:length(K)) {
    # kp <= f(k)
    maxval <- tibble(kp=K,vp=NA)
    for (j in 1:length(maxval$kp)) {
      kp <- maxval$kp[j]
      if (kp <= f(K[i])) {
        maxval$vp[j] <- log(f(K[i])-kp)+beta*vL[[2]][vL[[1]]==kp]
      }
    }
    m <- which.max(maxval$vp)
    gtemp$kp[i] <- maxval$kp[m]
    vtemp$V[i] <- maxval$vp[m]
  }
  v0 <- cbind(v0,vtemp$V)
  colnames(v0)[t+3] <- paste("V",t+1,sep="")
  g0 <- cbind(g0,gtemp$kp)
  colnames(g0)[t+2] <- paste("kp",t+1,sep="")
  tol <- max(abs(v0[[t+3]] - v0[[t+2]]))
  t <- t+1
# }

g0 <- cbind(g0,d=K)
gfinal <- melt(g0,id=c("K"))
gfinal <- gfinal[gfinal$variable%in%c("kp2","kp3","kp5","kp10",paste("kp",t,sep=""),"d"),]
ggplot(gfinal,aes(x=K,y=value,col=variable)) + 
  geom_point() + geom_line() + 
  theme_minimal() + theme_bw(base_size=15) + 
  theme(axis.title.x=element_text(size=18),
        axis.title.y=element_text(size=18)) + 
  xlab("k") + 
  ylab("g(k)") +
  ggtitle(paste("Policy functions until absolute maximum error\nof value functions between iterations < 10^(-6)\n",t," iterations, 0.01 increments",sep="")) +
  labs(color="Iteration")

vfinal <- melt(v0,id=c("K"))
vfinal <- vfinal[vfinal$variable%in%c("V1","V2","V3","V5","V10",paste("V",t,sep=""),"kp29"),]
ggplot(vfinal,aes(x=K,y=value,col=variable)) + 
  geom_point() + geom_line() + 
  theme_minimal() + theme_bw(base_size=15) + 
  theme(axis.title.x=element_text(size=18),
        axis.title.y=element_text(size=18)) + 
  xlab("k") + 
  ylab("v(k)") +
  ggtitle(paste("Value functions until absolute\nmaximum error between iterations < 10^(-6)\n",t," iterations, 0.01 increments",sep="")) +
  labs(color="Iteration")
