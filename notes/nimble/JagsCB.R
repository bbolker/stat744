require(R2jags)
options(mc.cores = parallel::detectCores())

rjags::set.factory("bugs::Conjugate", TRUE, type="sampler")

Jagsmod <- jags.model(file="CB.bug",data=data,inits=inits)

list.samplers(Jagsmod)

JagsCB <- jags(data=data,
               inits=inits,
               param = params,
               model.file = "CB.bug",
               n.iter = iterations,
               n.chains = length(inits))

print(JagsCB)

saveRDS(JagsCB,file="JagsCB")