begin;

create temporary table ew (
       school	       text,
       game_date       date,
       wp	       float,
       w	       integer,
       primary key (school, game_date)
);

insert into ew
(school, game_date, wp, w)
(
select
hn.school_name as school,
g.game_date,
(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10)
 as wp,
(case when outcome='W' then 1 else 0 end) as w
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
--join ncaa_sr.schools vn
--  on (vn.school_id)=(g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
--join ncaa_sr._factors y
--  on (y.parameter,y.level)=('year',g.year::text)
--join ncaa_sr._basic_factors i
--  on (i.factor)=('(Intercept)')
where
    g.year = 2017
and g.opponent_id is not null
and g.location is null
and g.team_score is not null
and g.opponent_score is not null
);

insert into ew
(school, game_date, wp, w)
(
select
vn.school_name as school,
g.game_date,
(1.0-(h.strength*o.exp_factor)^10/
((h.strength*o.exp_factor)^10+(v.strength*d.exp_factor)^10))
 as wp,
(case when outcome='L' then 1 else 0 end) as w
from ncaa_sr.games g
--join ncaa_sr.schools hn
--  on (hn.school_id)=(g.school_id)
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
--join ncaa_sr._factors y
--  on (y.parameter,y.level)=('year',g.year::text)
--join ncaa_sr._basic_factors i
--  on (i.factor)=('(Intercept)')
where
    g.year = 2017
and g.school_id is not null
and g.location is null
and g.team_score is not null
and g.opponent_score is not null
);

insert into ew
(school, game_date, wp, w)
(
select
hn.school_name as school,
g.game_date,
((h.strength)^10/
((h.strength)^10+(v.strength)^10))
 as wp,
(case when outcome='W' then 1 else 0 end) as w
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
where
    g.year = 2017
and g.opponent_id is not null
and g.location='N'
and g.team_score is not null
and g.opponent_score is not null
);

select school,
count(*) as g,
sum(w) as w,
sum(1-w) as l,
sum(wp)::numeric(3,1) as ew,
(sum(w)-sum(wp))::numeric(3,1) as diff
from ew
group by school
order by diff asc;

commit;

