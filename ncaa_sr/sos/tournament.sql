select
g.game_date as date,
g.type as type,
g.school_id as home,
g.opponent_id as away,
(case when g.location is null then 'H'
      else g.location
end) as loc,

(
(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10)
)::numeric(5,4) as pr,

(case when g.outcome='W' then 1.0-
(
(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10)
)
else (
(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10)
)
end
)::numeric(5,4) as diff,
g.outcome as wl
from ncaa_sr.games g
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
g.type='NCAA'
and g.year=2017
order by diff desc;


