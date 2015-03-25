select
p.year,
sum(
(h.strength*o.exp_factor)^10.25/
((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25)
)::numeric(4,2) as e_home_wins,
sum(case when (p.visitor_score<p.home_score) then 1
    else 0 end) as home_wins
from ncaa_sr.playoffs p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
--where p.year=2015
group by p.year
order by p.year asc;

select
p.year,
(sum(
case when ((h.strength*o.exp_factor)>(v.strength*d.exp_factor)
            and p.home_score>p.visitor_score) then 1
     when ((h.strength*o.exp_factor)<(v.strength*d.exp_factor)
            and p.home_score<p.visitor_score) then 1
else 0 end)::float/
count(*))::numeric(4,2) as model,
(sum(
case when p.home_score>p.visitor_score then 1
else 0 end)::float/
count(*))::numeric(4,2) as naive,

(sum(
case when ((h.strength*o.exp_factor)>(v.strength*d.exp_factor)
            and p.home_score>p.visitor_score) then 1
     when ((h.strength*o.exp_factor)<(v.strength*d.exp_factor)
            and p.home_score<p.visitor_score) then 1
else 0 end)::float/
count(*)-
sum(
case when p.home_score>p.visitor_score then 1
else 0 end)::float/
count(*))::numeric(4,2) as diff,
count(*)
from ncaa_sr.playoffs p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
group by p.year
order by p.year asc;

select
(sum(
case when ((h.strength*o.exp_factor)>(v.strength*d.exp_factor)
            and p.home_score>p.visitor_score) then 1
     when ((h.strength*o.exp_factor)<(v.strength*d.exp_factor)
            and p.home_score<p.visitor_score) then 1
else 0 end)::float/
count(*))::numeric(4,2) as model,
(sum(
case when p.home_score>p.visitor_score then 1
else 0 end)::float/
count(*))::numeric(4,2) as naive,

(sum(
case when ((h.strength*o.exp_factor)>(v.strength*d.exp_factor)
            and p.home_score>p.visitor_score) then 1
     when ((h.strength*o.exp_factor)<(v.strength*d.exp_factor)
            and p.home_score<p.visitor_score) then 1
else 0 end)::float/
count(*)-
sum(
case when p.home_score>p.visitor_score then 1
else 0 end)::float/
count(*))::numeric(4,2) as diff,
count(*)
from ncaa_sr.playoffs p
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(p.year,p.visitor_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(p.year,p.home_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home');

