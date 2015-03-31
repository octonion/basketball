begin;

create temporary table ew (
       school	       text,
       coach	       text,
       game_date       date,
       wp	       float,
       w	       integer,
       primary key (school, coach, game_date)
);

/*
insert into ew
(school, coach, game_date, wp, w)
(
select
hn.school_name as school,
c.coach as coach,
g.game_date,
(h.strength*o.exp_factor)^10.25/
((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25)
 as wp,
(case when outcome='W' then 1 else 0 end) as w
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.coaches c
  on (c.year,c.school_id)=(g.year,g.school_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')

where
    g.year between 1980 and 2014
and g.type in ('NCAA')
and g.opponent_id is not null
and g.location is null
and g.team_score is not null
and g.opponent_score is not null
);

insert into ew
(school, coach, game_date, wp, w)
(
select
vn.school_name as school,
c.coach as coach,
g.game_date,
(1.0-(h.strength*o.exp_factor)^10.25/
((h.strength*o.exp_factor)^10.25+(v.strength*d.exp_factor)^10.25))
 as wp,
(case when outcome='L' then 1 else 0 end) as w
from ncaa_sr.games g
join ncaa_sr.schools vn
  on (vn.school_id)=(g.opponent_id)
join ncaa_sr.coaches c
  on (c.year,c.school_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
join ncaa_sr._factors o
  on (o.parameter,o.level)=('field','offense_home')
join ncaa_sr._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
    g.year between 1980 and 2014
and g.type in ('NCAA')
and g.school_id is not null
and g.location is null
and g.team_score is not null
and g.opponent_score is not null
);
*/

insert into ew
(school, coach, game_date, wp, w)
(
select
hn.school_name as school,
c.coach,
g.game_date,
((h.strength)^10.25/
((h.strength)^10.25+(v.strength)^10.25))
 as wp,
(case when outcome='W' then 1 else 0 end) as w
from ncaa_sr.games g
join ncaa_sr.schools hn
  on (hn.school_id)=(g.school_id)
join ncaa_sr.coaches c
  on (c.year,c.school_id)=(g.year,g.school_id)
join ncaa_sr.beta_schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join ncaa_sr.beta_schedule_factors h
  on (h.year,h.team_id)=(g.year,g.school_id)
where
    g.year between 1985 and 2015
and g.type in ('NCAA')
and g.opponent_id is not null
and g.location='N'
and g.team_score is not null
and g.opponent_score is not null
);

/*
select school,coach,
count(*) as g,
sum(w) as w,
sum(1-w) as l,
sum(wp)::numeric(3,1) as ew,
(sum(w)-sum(wp))::numeric(3,1) as diff
from ew
group by school,coach
order by diff desc;
*/

select coach,
count(*) as g,
sum(w) as w,
sum(1-w) as l,
sum(wp)::numeric(3,1) as ew,
(sum(w)-sum(wp))::numeric(3,1) as diff
from ew
group by coach
order by diff desc;

copy
(
select coach,
count(*) as g,
sum(w) as w,
sum(1-w) as l,
sum(wp)::numeric(3,1) as ew,
(sum(w)-sum(wp))::numeric(3,1) as diff
from ew
group by coach
order by diff desc
) to '/tmp/coaches_tournament.csv' csv header;

commit;

