library("EasyABC")

sum_stat_obs <- c(richness=100,shannon=2.5,meantrait=20,skewness=30000)
trait_prior <- list(c("unif",3,5),
                   c("unif",-2.3,1.6),
                   c("unif",-25,125),
                   c("unif",-.7,3.2))
set.seed(101)
usr <- if (.Platform$OS.type=="unix") {
    Sys.getenv("USER")
} else Sys.getenv("USER.NAME")

run_abc <- function(FUN,...) {
    FUN(model=trait_model,
        prior=trait_prior,
        summary_stat_target=sum_stat_obs,
        use_seed=TRUE,
        ...)
}

sum_abc <- function(fit) 
    c(fit$computime,mean(fit$stats[,4]),sd(fit$stats[,4]))
r_rej <- r_mcmc <- r_mcmcnew <- matrix(NA,nrow=5,ncol=3,
             dimnames=list(NULL,c("time","s4mean","s4sd")))
for (i in 1:5) {
   r_rej[i,] <- sum_abc(run_abc(ABC_rejection,tol=0.1,nb_simul=100))
   r_mcmc[i,] <- sum_abc(run_abc(ABC_mcmc,method="Marjoram_original",
                             n_rec=10,dist_max=0.2))
   r_mcmcnew[i,] <- sum_abc(run_abc(ABC_mcmc,method="Marjoram",
                                    n_rec=10,n_calibration=10,
                                    tolerance_quantile=0.2))
}

ss <- sessionInfo()

save("r_rej","r_mcmc","r_mcmcnew","ss","usr",
     file="abc_bench.rda")
