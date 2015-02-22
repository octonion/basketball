select
0 as id,'H/A',
array(
select
distinct sf.team_id
from ncaa_sr._schedule_factors sf
where sf.year=2015
order by sf.team_id asc
)
union
(
select
row_number() over (order by home.team_id) as id,home.team_id,
array(
select
((
(home.strength*o.exp_factor)^16/
((home.strength*o.exp_factor)^16+(visit.strength*d.exp_factor)^16)
)::numeric(3,2))::text
as out
from ncaa_sr._schedule_factors visit
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
where visit.year=home.year
order by visit.team_id asc
)
from ncaa_sr._schedule_factors home
where home.year=2015
)
order by id asc;

