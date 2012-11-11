sink("feature_selection_sos.txt")

library(MASS)
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,host="localhost",port="5432",dbname="basketball")

query <- dbSendQuery(con, "
select
split_part(n.height,'-',1)::integer*12+split_part(n.height,'-',2)::integer as height,
--d.pick as pick,
--sqrt(d.pick) as s_pick,
lower(n.position) as position,
s.offensive,
s.defensive,
s.strength,
s.schedule_offensive,
s.schedule_defensive,
s.schedule_strength,
s.schedule_offensive_all,
s.schedule_defensive_all,
n.games,
n.field_goals::float/nullif(n.field_goal_attempts,0) as fgp,
--n.three_pointers::float/nullif(n.three_pointer_attempts,0) as tpp,
n.free_throws::float/nullif(n.free_throw_attempts,0) as ftp,
n.rebounds_per_game,
n.assists_per_game,
--n.blocks_per_game,
n.steals_per_game,
n.points_per_game,
n.rebounds,
n.assists,
n.blocks,
n.steals,
n.points,
sum(b.minutes_played) as minutes_played
from ncaa.statistics n
join alias.players p
  on (p.ncaa_id)=(n.player_id)
join bbref.draft_picks d
  on (d.player_id,d.year)=(p.bbref_id,n.year)
join bbref.basic_statistics b
  on (b.player_id,b.year)=(d.player_id,d.year+1)
join ncaa._schedule_factors s
  on (s.school_id,s.year)=(n.school_id,n.year)
where
  not(b.team_id='TOT')
and not(n.three_pointer_attempts=0)
group by
s.offensive,
s.defensive,
s.strength,
s.schedule_offensive,
s.schedule_defensive,
s.schedule_strength,
s.schedule_offensive_all,
s.schedule_defensive_all,
height,
--d.pick,
--s_pick,
position,
n.games,
fgp,
--tpp,
ftp,
n.rebounds_per_game,
n.assists_per_game,
--n.blocks_per_game,
n.steals_per_game,
n.points_per_game,
n.rebounds,
n.assists,
n.blocks,
n.steals,
n.points
--order by minutes_played desc;
");

players <- fetch(query,n=-1)
dim(players)

players$position <- as.factor(players$position)

model <- minutes_played ~ .

fit <- lm(model,data=players)
out <- stepAIC(fit,direction="both",k=2)
out$anova

coef(out)
AIC(out)
deviance(out)
summary(out)
out

quit("no")
