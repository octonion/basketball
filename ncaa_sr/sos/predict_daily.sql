begin;

set timezone to 'America/New_York';

select
g.game_date::date as date,
'home' as site,
hn.school_name as home,
(h.strength*o.exp_factor)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as score,
vn.school_name as away,
(v.strength*d.exp_factor)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as score,
(
(h.strength*o.exp_factor)^10.25/
((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25)
)::numeric(4,2) as pwin
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa_sr._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr._basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.game_date::date = current_date
and g.location is null

union all

select
g.game_date::date as date,
'neutral' as site,
hn.school_name as home,
(h.strength)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*h.offensive*v.defensive)::numeric(4,1) as score,
vn.school_name as away,
(v.strength)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive)::numeric(4,1) as score,
(
(h.strength)^10.25/
((h.strength)^10.25+(v.strength)^10.25)
)::numeric(4,2) as pwin
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr._basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.game_date::date = current_date
and g.location='N'

order by home asc;

copy
(
select
g.game_date::date as date,
'home' as site,
hn.school_name as home,
(h.strength*o.exp_factor)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as score,
vn.school_name as away,
(v.strength*d.exp_factor)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as score,
(
(h.strength*o.exp_factor)^10.25/
((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25)
)::numeric(4,2) as pwin
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
join ncaa_sr._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr._basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.game_date::date = current_date
and g.location is null

union all

select
g.game_date::date as date,
'neutral' as site,
hn.school_name as home,
(h.strength)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*h.offensive*v.defensive)::numeric(4,1) as score,
vn.school_name as away,
(v.strength)::numeric(4,2) as str,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive)::numeric(4,1) as score,
(
(h.strength)^10.25/
((h.strength)^10.25+(v.strength)^10.25)
)::numeric(4,2) as pwin
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join ncaa_sr._basic_factors i
  on (i.factor)=('(Intercept)')
where
    g.game_date::date = current_date
and g.location='N'

order by home asc
) to '/tmp/predict_daily.csv' csv header;

commit;
