sink("diagnostics/ncaa_sr_nbinom.txt")

library(lme4)
library(nortest)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="basketball")

query <- dbSendQuery(con, "
select
r.game_id,
r.year,
r.field as field,

(
case
  when r.field='offense_home' then r.team_id::text||'/'||field
  when r.field='defense_home' then r.opponent_id::text||'/'||field
end)
as team_field,

r.team_id as team,
r.opponent_id as opponent,
--r.team_previous as team_previous,
--r.opponent_previous as opponent_previous,
r.game_length as game_length,
r.team_score as ps,
ln(r.team_score::float) as log_ps
from ncaa_sr.results r
where
TRUE
and r.year between 1950 and 2015
and r.team_score>0
and r.opponent_score>0
and not(r.team_score,r.opponent_score)=(0,0)
;")

games <- fetch(query,n=-1)
dim(games)

attach(games)

pll <- list()

# Fixed parameters

year <- as.factor(year)
#contrasts(year)<-'contr.sum'

field <- as.factor(field)

#team_previous <- as.factor(team_previous)
#opponent_previous <- as.factor(opponent_previous)

#fp <- data.frame(year,field,game_length,team_previous,opponent_previous)

fp <- data.frame(year,field,game_length)
fpn <- names(fp)

# Random parameters

game_id <- as.factor(game_id)
#contrasts(game_id) <- 'contr.sum'

offense <- as.factor(paste(year,"/",team,sep=""))
#contrasts(offense) <- 'contr.sum'

defense <- as.factor(paste(year,"/",opponent,sep=""))
#contrasts(defense) <- 'contr.sum'

#team_field <- as.factor(team_field)
#contrasts(team_field) <- 'contr.sum'

rp <- data.frame(game_id,offense,defense)
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
dbWriteTable(con,c("ncaa_sr","_parameter_levels"),parameter_levels,row.names=TRUE)

g <- cbind(fp,rp)

g$ps <- ps

dim(g)

model <- ps ~ year+field+game_length+(1|offense)+(1|defense)+(1|game_id)
fit <- glmer(model, data=g, REML=FALSE)
#fit0
#summary(fit0)

#model <- log_ps ~ year*field+game_length+(1|offense)+(1|defense)+(1|game_id)

#fit <- lmer(model, data=g, REML=FALSE)
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

dbWriteTable(con,c("ncaa_sr","_basic_factors"),as.data.frame(combined),row.names=TRUE)

quit("no")
