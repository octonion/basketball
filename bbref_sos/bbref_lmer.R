library("lme4")

library("RPostgreSQL")

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="basketball")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.field as field,
r.team_id as team,
r.opponent_id as opponent,
ln(r.team_score::float) as log_ps
from bbref.results r
where
TRUE
and r.year between 2002 and 2013
and r.team_score>0
and r.opponent_score>0
and not(r.team_score,r.opponent_score)=(0,0)
;")

games <- fetch(query,n=-1)
dim(games)

attach(games)

model <- log_ps ~ 1+year+field+(1|offense)+(1|defense)+(1|game_id)

pll <- list()

# Fixed parameters

year <- as.factor(year)
field <- as.factor(field)

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
dbWriteTable(con,c("bbref","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

g$log_ps <- log_ps

dim(g)

fit <- lmer(model,data=g)

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

dbWriteTable(con,c("bbref","_basic_factors"),as.data.frame(combined),row.names=TRUE)

quit("no")
