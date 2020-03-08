## Creates barcode plot for JEP paper
# Jann Spiess, March/April 2017
# edited by Elmer Li

########################################################################
## Load and prepare data

setwd("/Users/zongyangli/Google Drive/Cornell PhD/3rd Semester/Labor Seminar/PS/PS 3/")
basedata <- readRDS(file=paste0("ahs2011forjep.rdata"))

# subtract from dataframe
  localahs <- basedata$df # the data matrix
  Y <- localahs[,"LOGVALUE"] # the Y variable
  thisrhs <- paste(basedata$vars,collapse=" + ") # specify the RHV
# tranlate all var into dummies
  X <- model.matrix(as.formula(paste("LOGVALUE", thisrhs, sep = " ~ ")),localahs)


########################################################################
## Select & fix tuning parameter

# pick the training sample
  set.seed(123)
  firstsubsample <- sample(nrow(localahs),nrow(localahs)/10)
# run LASSO
  library(glmnet)
  firstlasso <- glmnet(X[firstsubsample,],Y[firstsubsample]) # there are 89 lambdas from this LASSO
# compute MSE, select lambda
  losses <- apply(predict(firstlasso,newx=X[-firstsubsample,]),2, function(Yhat) mean((Yhat - Y[-firstsubsample])^2)) 
      # apply: 2 apply to column. Yhat produced by the prediction on each of 89 lambda. function of Yhat - let Yhat minus the true Y
  plot(log(firstlasso$lambda),losses)
  lambda <- firstlasso$lambda[which.min(losses)]


########################################################################
## Fit LASSO models

I <- length(unique(localahs$lassofolds))

barcodes <- matrix(0,nrow=I,ncol=firstlasso$dim[1]) # firstlasso$dim[1] should be tot # of var
lassonormcoeff <- matrix(0,nrow=I,ncol=firstlasso$dim[1])
lassolosses <- vector(mode='numeric',length=I)
lassose <- vector(mode='numeric',length=I)

for(i in 1:I) {
  thissubsample <- localahs$lassofolds == i
  
  thislasso <- glmnet(X[thissubsample,],Y[thissubsample])
  thislosses <- apply(predict(thislasso,newx=X[-thissubsample,]),2,function(Yhat) mean((Yhat - Y[-thissubsample])^2))
  thislambda <- firstlasso$lambda[which.min(thislosses)] # fix the lambda to be the previous one
  
  barcodes[i,as.vector(!(thislasso$beta[,which.min(thislosses)] == 0))] <- 1
      # thislasso$beta are the variables & coeff. assign one to those coeff that aren't shank to 0 by LASSO
  pointlosses <- (predict(thislasso,newx=X[-thissubsample,],s=thislambda) - Y[-thissubsample])^2
  lassolosses[i] <- mean(pointlosses)
  lassose[i] <- sd(pointlosses) / sqrt(length(pointlosses))
}


# Barcode plot

library(reshape2)
library(ggplot2)

barcodeplotdata <- melt(barcodes)
names(barcodeplotdata) <- c("Iteration","Coefficient","Selected")
barcodeplotdata$Selected <- as.factor(barcodeplotdata$Selected)
barcodeplotdata$Iteration <- as.factor(barcodeplotdata$Iteration)

barcodeplot <- ggplot(data = barcodeplotdata, aes(x=Iteration, y=Coefficient, fill=Selected)) + 
  geom_tile() + scale_fill_manual(values=c("white","black"),labels=c("zero", "nonzero")) + theme_bw() +
  labs(list(x = "Fold of the sample", y = "Parameter in the linear model",fill="Estimate")) +
  theme(axis.text.y=element_blank(),
        axis.ticks.y=element_blank())

print(barcodeplot)
ggsave(barcodeplot,file="barcode.png")

