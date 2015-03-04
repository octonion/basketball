sink("diagnostics/geo_gamm4.txt")

library("mgcv")
library("nortest")
library("RPostgreSQL")

#library("sp")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="basketball")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.field as field,

distance_in_km(site.latitude,site.longitude,team.latitude,team.longitude)
as team_distance,

distance_in_km(site.latitude,site.longitude,opponent.latitude,opponent.longitude)
as opponent_distance,

r.school_id as team,
r.school_div_id as o_div,
r.opponent_id as opponent,
r.opponent_div_id as d_div,
ln(r.team_score::float) as log_ps
from ncaa.results r
join ncaa.geocodes site
  on (site.school_id)=(r.location_id)
join ncaa.geocodes team
  on (team.school_id)=(r.school_id)
join ncaa.geocodes opponent
  on (opponent.school_id)=(r.opponent_id)
where
    r.year between 2012 and 2015
and r.school_div_id is not null
and r.opponent_div_id is not null
and r.team_score>0
and r.opponent_score>0
and not(r.team_score,r.opponent_score)=(0,0)
and r.school_div_id in (1)
and r.opponent_div_id in (1)

;")

games <- fetch(query,n=-1)

dim(games)

attach(games)

#games$dist <- spDists(rbind(site_long,site_lat),rbind(home_long,home_lat),longlat=TRUE)
  
pll <- list()

# Fixed parameters

year <- as.factor(year)
field <- as.factor(field)
d_div <- as.factor(d_div)
o_div <- as.factor(o_div)

fp <- data.frame(year,field,d_div,o_div)
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
#dbWriteTable(con,c("ncaa","_geo_parameter_levels"),
#	parameter_levels, row.names=TRUE)

g <- cbind(fp,rp)

g$log_ps <- log_ps

dim(g)

model0 <- log_ps ~ year + field + s(team_distance,opponent_distance) + s(offense,bs="re") + s(defense,bs="re") + s(game_id,bs="re")

fit0 <- bam(model0, data=g, verbose=TRUE)
fit0
summary(fit0)

#model1 <- log_ps ~ year + field + d_div + o_div + s(team_distance) + s(offense,bs="re") + s(defense,bs="re") + s(game_id,bs="re")
#random1 <- list(offense=~1, defense=~1, game_id=~1)

#fit1 <- bam(model1, data=g, random=random1, method="ML", verbose=TRUE)

#model2 <- log_ps ~ year + field + d_div + o_div + s(team_distance) + s(opponent_distance)
#random2 <- list(offense=~1, defense=~1, game_id=~1)
#fit2 <- bam(model2, data=g, random=random2, method="ML", verbose=TRUE)

#fit2
#summary(fit2)

anova(fit0)
#anova(fit2)
#anova(fit0,fit2)
#anova(fit0,fit1)
#anova(fit1,fit2)

quit("no")

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

#dbWriteTable(con, c("ncaa","_geo_basic_factors"),
#		  as.data.frame(combined), row.names=TRUE)

f <- fitted(fit) 
r <- residuals(fit)

# Jackknife - 4500 data points 1000 times

subs=4500
iter=1000

# Vector of results

pvals=rep(NA, iter)

# Sample p-values

for(i in 1:iter){
samp=sample(1:length(r),4500)
p.i=sf.test(r[samp])$p.value
pvals[i]=p.i
}

# Sampled p-value statistics

mean(pvals)
median(pvals)
sd(pvals)

# Graph p-values

jpeg("diagnostics/geo_shapiro-francia.jpg")
hist(pvals,xlim=c(0,1))
abline(v=0.05,lty='dashed',lwd=2,col='red')
quantile(pvals,prob=seq(0,1,0.05))

# Examine residuals

jpeg("diagnostics/geo_fitted_vs_residuals.jpg")
plot(f,r)
jpeg("diagnostics/geo_q-q_plot.jpg")
qqnorm(r,main="Q-Q plot for residuals")

quit("no")
