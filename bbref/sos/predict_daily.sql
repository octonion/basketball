begin;

set timezone to 'America/New_York';

select
g.game_date::date as date,
g.home_id as home,
g.visitor_id as opp,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as t_score,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as o_score,
(h.strength*o.exp_factor)::numeric(4,2) as h_str,
(v.strength*d.exp_factor)::numeric(4,2) as o_str,
(
(h.strength*o.exp_factor)^16/
((h.strength*o.exp_factor)^16+(v.strength*d.exp_factor)^16)
)::numeric(4,2) as pr_home
from bbref.games g
join bbref._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.visitor_id)
join bbref._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.home_id)
join bbref._factors o
  on (o.parameter,o.level)=('field','offense_home')
join bbref._factors d
  on (d.parameter,d.level)=('field','defense_home')
join bbref._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join bbref._basic_factors i
  on (i.factor)=('(Intercept)')
where g.game_date::date = current_date
order by g.game_date::date,g.home_id asc;

commit;
