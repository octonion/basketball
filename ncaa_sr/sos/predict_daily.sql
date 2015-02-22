begin;

set timezone to 'America/Los_Angeles';

select
g.game_date::date as date,
hn.school_name as home,
vn.school_name as opp,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as t_score,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as o_score,
(h.strength*o.exp_factor)::numeric(4,2) as h_str,
(v.strength*d.exp_factor)::numeric(4,2) as o_str,
(
(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10)
)::numeric(4,2) as pr_home
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
order by g.game_date::date,g.school_id asc;

commit;
