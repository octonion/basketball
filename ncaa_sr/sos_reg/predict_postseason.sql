begin;

select
year,
type,
sum(correct),
sum(n),
(sum(correct)::float/sum(n)::float)::numeric(4,3) as pct
from
(
select
--g.game_date::date as date,
g.year as year,
g.type as type,
--'home' as site,
--hn.school_name as home,
--(h.strength*o.exp_factor)::numeric(4,2) as str,
--(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as score,
--vn.school_name as away,
--(v.strength*d.exp_factor)::numeric(4,2) as str,
--(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as score,
--(
--(h.strength*o.exp_factor)^10.25/
--((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25)
--)::numeric(4,2) as pwin

(case
when (exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive >
      exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)
     and g.team_score > g.opponent_score then 1
when (exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive <
      exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)
     and g.team_score < g.opponent_score then 1
else 0 end) as correct,
1 as n

from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr.beta_schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr.beta_schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr.beta_factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr.beta_factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa_sr.beta_factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr.beta_basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.location is null
and g.type not in ('REG','CTOURN')
and g.team_score is not null
and g.opponent_score is not null

union all

select
--g.game_date::date as date,
g.year as year,
g.type as type,
--'neutral' as site,
--hn.school_name as home,
--(h.strength)::numeric(4,2) as str,
--(exp(i.estimate)*y.exp_factor*h.offensive*v.defensive)::numeric(4,1) as score,
--vn.school_name as away,
--(v.strength)::numeric(4,2) as str,
--(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive)::numeric(4,1) as score,
--(
--(h.strength)^10.25/
--((h.strength)^10.25+(v.strength)^10.25)
--)::numeric(4,2) as pwin,

(case
when (exp(i.estimate)*y.exp_factor*h.offensive*v.defensive >
      exp(i.estimate)*y.exp_factor*v.offensive*h.defensive)
     and g.team_score > g.opponent_score then 1
when (exp(i.estimate)*y.exp_factor*h.offensive*v.defensive <
      exp(i.estimate)*y.exp_factor*v.offensive*h.defensive)
     and g.team_score < g.opponent_score then 1
else 0 end) as correct,
1 as n

from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr.beta_schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr.beta_schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr.beta_factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr.beta_basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.location='N'
and g.school_id < g.opponent_id
and g.type not in ('REG','CTOURN')

and g.team_score is not null
and g.opponent_score is not null

) as playoffs
group by year,type
order by year,type;

commit;
