sink("diagnostics/geo_lmer.txt")

library("lme4")
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
--site.longitude as site_long,
--site.latitude as site_lat,
--home.longitude as home_long,
--home.latitude as home_lat,

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
    r.year between 2002 and 2015
and r.school_div_id is not null
and r.opponent_div_id is not null
and r.team_score>0
and r.opponent_score>0
and not(r.team_score,r.opponent_score)=(0,0)

-- fit all excluding March and April
--and not(extract(month from r.game_date)) in (3,4)

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
dbWriteTable(con,c("ncaa","_geo_parameter_levels"),
	parameter_levels, row.names=TRUE)

g <- cbind(fp,rp)

g$log_ps <- log_ps

dim(g)

model0 <- log_ps ~ year+field+d_div+o_div+(1|offense)+(1|defense)+(1|game_id)
fit0 <- lmer(model0,data=g,REML=F,verbose=T) #,control=list(maxIter=5000))

model1 <- log_ps ~ year+field+d_div+o_div+(1|offense)+(1|defense)+(1|game_id)+team_distance
fit1 <- lmer(model1,data=g,REML=F,verbose=T)

model <- log_ps ~ year+field+d_div+o_div+(1|offense)+(1|defense)+(1|game_id)+team_distance+opponent_distance
fit <- lmer(model,data=g,REML=F,verbose=T)

fit
summary(fit)

anova(fit0)
anova(fit)
anova(fit0,fit)
anova(fit0,fit1)
anova(fit1,fit)

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

dbWriteTable(con, c("ncaa","_geo_basic_factors"),
		  as.data.frame(combined), row.names=TRUE)

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
