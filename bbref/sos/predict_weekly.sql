select
p.home_id as home,
p.game_date as date,
p.visitor_id as opp,
(h.strength*o.exp_factor)::numeric(4,2) as h_str,
(v.strength*d.exp_factor)::numeric(4,2) as o_str,
(
(h.strength*o.exp_factor)^16/
((h.strength*o.exp_factor)^16+(v.strength*d.exp_factor)^16)
)::numeric(4,2) as pr_home
from bbref.games p
join bbref._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join bbref._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join bbref._factors o
  on (o.parameter,o.level)=('field','offense_home')
join bbref._factors d
  on (d.parameter,d.level)=('field','defense_home')
where p.game_date::date between current_date-3 and current_date+6
order by p.game_date::date,p.home_id asc;
