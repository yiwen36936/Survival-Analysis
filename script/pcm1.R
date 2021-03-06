pcm.cv <- function(data, cur.tt, n.step=100, lower=quantile(cur.tt,.9),
                   upper=quantile(cur.tt,1-(2/nrow(data$x))), n.fold=10) 
{
  require(survival)
  n <- ncol(data$x)
  breaks <- round(seq(from=1,to=(n+1),length=(n.fold+1)))
  cv.order <- sample(1:n)
  th <- seq(from=lower, to=upper, length=n.step)
  best.w <- 0
  for (i in 1:n.step) {
    cat(i)
    cat("\n")
    cur.genes <- (cur.tt>th[i])
    w.vec <- rep(NA,n.fold)
    for (j in 1:n.fold) {
      cur.lo <- cv.order[(breaks[j]):(breaks[j+1]-1)]
      cur.svd <- svd(data$x[cur.genes,-cur.lo])
      cur.v <- t(data$x[cur.genes,cur.lo]) %*%
        cur.svd$u %*% diag(1/cur.svd$d)
      result=tryCatch({coxph(Surv(data$y[cur.lo],
                            data$icens[cur.lo])~cur.v[,1])},
               warning=function(w) {
                 w.vec[j]<<-0
               }
             )
      if(is.na(w.vec[j])) {
      cur.cox=coxph(Surv(data$y[cur.lo],
                 data$icens[cur.lo])~cur.v[,1])
      w.vec[j] <- cur.cox$wald.test
      }      
    }
    numzer=table(w.vec)
    print(numzer[names(numzer)==0])
    remove=c(0)
    w.vec=w.vec[!w.vec %in% remove]
    cur.w <- mean(w.vec)
    
    print(cur.w)
    if (cur.w > best.w) {
      best.th <- th[i]
      best.w <- cur.w
    }
  }
  cur.genes <- (cur.tt>best.th)
  b=table(cur.genes)
  print(b[names(b)==TRUE])
  return(best.th)
}