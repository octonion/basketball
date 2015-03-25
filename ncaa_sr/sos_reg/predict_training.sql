select
p.home_id as home,
--p.visitor_id as opp,
sum(case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) and p.home_score>p.visitor_score then 1
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) and p.home_score<p.visitor_score then 1
else 0 end) as right,
sum(case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) and p.home_score>p.visitor_score then 0
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) and p.home_score<p.visitor_score then 0
else 1 end) as wrong
from ncaa_sr.games p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
where p.year=2015
and p.home_score is not null
and p.visitor_score is not null
group by p.home_id
order by p.home_id asc;

select
sum(case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) and p.home_score>p.visitor_score then 1
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) and p.home_score<p.visitor_score then 1
else 0 end) as right,
sum(case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) and p.home_score>p.visitor_score then 0
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) and p.home_score<p.visitor_score then 0
else 1 end) as wrong,
sum(case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) then 1
else 0 end) as pr_home,
sum(case
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) then 1
else 0 end) as pr_visitor,
sum(case when p.home_score>p.visitor_score then 1 else 0 end) as home,
sum(case when p.home_score<p.visitor_score then 1 else 0 end) as visitor
from ncaa_sr.games p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
where p.year=2015
and p.home_score is not null
and p.visitor_score is not null;

select
(
case
when p.home_score>p.visitor_score then 'home'
else 'away' end) as "w/p",
sum(
case
when (h.strength*o.exp_factor)>(v.strength*d.exp_factor) then 1
else 0 end) as home,
sum(
case
when (h.strength*o.exp_factor)<(v.strength*d.exp_factor) then 1
else 0 end) as away
from ncaa_sr.games p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
where p.year=2015
and p.home_score is not null
and p.visitor_score is not null
group by "w/p"
order by "w/p" desc;

