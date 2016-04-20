sink("diagnostics/lmer.txt")

library("lme4")
library("nortest")
library("RPostgreSQL")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="basketball")

query <- dbSendQuery(con, "
select
r.game_id,
r.year as year,
r.field as field,
r.team_id as team,
r.opponent_id as opponent,
r.game_length as game_length,
ln(r.team_score::float) as log_ps
from euro.results r

where
    r.year between 2013 and 2015

and r.team_score is not null
and r.opponent_score is not null
and r.team_score > 0
and r.opponent_score > 0
;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- factor(year)

field <- factor(field)

fp <- data.frame(year,field)
fpn <- names(fp)

# Random parameters

game_id <- as.factor(game_id)

offense <- as.factor(paste(year,"/",team,sep=""))

defense <- as.factor(paste(year,"/",opponent,sep=""))

rp <- data.frame(offense,defense)
rpn <- names(rp)

for (n in fpn) {
  df <- fp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("fixed",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

for (n in rpn) {
  df <- rp[[n]]
  level <- as.matrix(attributes(df)$levels)
  parameter <- rep(n,nrow(level))
  type <- rep("random",nrow(level))
  pll <- c(pll,list(data.frame(parameter,type,level)))
}

# Model parameters

parameter_levels <- as.data.frame(do.call("rbind",pll))
dbWriteTable(con,c("euro","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

g$log_ps <- log_ps

dim(g)

model0 <- log_ps ~ year+field+(1|offense)+(1|defense)
fit0 <- lmer(model0,data=g,REML=T,verbose=T)

model <- log_ps ~ year+field+(1|offense)+(1|defense)+(1|game_id)
fit <- lmer(model,data=g,REML=T,verbose=T)

fit
summary(fit)

anova(fit0)
anova(fit)
anova(fit0,fit)

# List of data frames

# Fixed factors

f <- fixef(fit)
fn <- names(f)

# Random factors

r <- ranef(fit)
rn <- names(r)

results <- list()

for (n in fn) {

  df <- f[[n]]

  factor <- n
  level <- n
  type <- "fixed"
  estimate <- df

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

for (n in rn) {

  df <- r[[n]]

  factor <- rep(n,nrow(df))
  type <- rep("random",nrow(df))
  level <- row.names(df)
  estimate <- df[,1]

  results <- c(results,list(data.frame(factor,type,level,estimate)))

 }

combined <- as.data.frame(do.call("rbind",results))

dbWriteTable(con,c("euro","_basic_factors"),as.data.frame(combined),row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Jackknife - 4500 data points 1000 times

subs=500
iter=1000

# Vector of results

pvals=rep(NA, iter)

# Sample p-values

for(i in 1:iter){
samp=sample(1:length(r),500)
p.i=sf.test(r[samp])$p.value
pvals[i]=p.i
}

# Sampled p-value statistics

mean(pvals)
median(pvals)
sd(pvals)

# Graph p-values

jpeg("diagnostics/shapiro-francia.jpg")
hist(pvals,xlim=c(0,1))
abline(v=0.05,lty='dashed',lwd=2,col='red')
quantile(pvals,prob=seq(0,1,0.05))

# Examine residuals

jpeg("diagnostics/fitted_vs_residuals.jpg")
plot(f,r)
jpeg("diagnostics/q-q_plot.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
