library(parallel)
library(doMC); library(doParallel)

## Loading required package: foreach

## Loading required package: iterators
k <- 5
burnin <- 4000
iter <- 2000
thin <- 500
seed <- 2003
nstart <- 1
best <- TRUE

ctrl <- list(nstart=nstart,
             seed=seed,
             best=best,
             burnin=burnin,
             iter=iter,
             thin=thin)

cl <- makeCluster(detectCores() - 2)
registerDoParallel(cl)

mlist <- foreach(i=seq(2, 29, 3),
                 .packages="topicmodels",
                 .export=c("ctrl", "dtm")) %dopar% {
                   out <- LDA(dtm,
                              i,
                              method="Gibbs",
                              control=ctrl)
                   return(out)
                 }

mlogLik <- as.data.frame(as.matrix(lapply(mlist, logLik)))
## mperp <- as.data.frame(as.matrix(lapply(mlist, perplexity)))

beep(sound="mario")

x <- seq(2, 29, 3)
f_x <- unlist(mlogLik)

plot(x,
     f_x,
     xlab="Number of Topics",
     ylab="Log-likelihood", main = 'CDF by number of themes - Agregate', pch=19)
lines(x[order(x)], f_x[order(x)], xlim=range(x), ylim=range(f_x), pch=14)