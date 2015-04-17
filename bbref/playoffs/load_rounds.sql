begin;

-- rounds

drop table if exists bbref.rounds;

create table bbref.rounds (
	year				integer,
	round_id			integer,
	team_id				text,
	conference_id			text,
	seed				integer,
	bracket				int[],
	p				float,
	primary key (year,round_id,team_id)
);

copy bbref.rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

-- matchup probabilities

drop table if exists bbref.matrix_p;

create table bbref.matrix_p (
	year				integer,
	home_id				text,
	visitor_id			text,
	home_p				float,
	visitor_p			float,
	primary key (year,home_id,visitor_id)
);

insert into bbref.matrix_p
(year,home_id,visitor_id,home_p,visitor_p)
(select
r1.year,
r1.team_id,
r2.team_id,
(h.strength*o.exp_factor)^14.0/
((h.strength*o.exp_factor)^14.0+(v.strength*d.exp_factor)^14.0)
  as home_p,
(v.strength*d.exp_factor)^14.0/
((v.strength*d.exp_factor)^14.0+(h.strength*o.exp_factor)^14.0)
  as visitor_p
from bbref.rounds r1
join bbref.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
join bbref._schedule_factors v
  on (v.year,v.team_id)=(r2.year,r2.team_id)
join bbref._schedule_factors h
  on (h.year,h.team_id)=(r1.year,r1.team_id)
join bbref._factors o
  on (o.parameter,o.level)=('field','offense_home')
join bbref._factors d
  on (d.parameter,d.level)=('field','defense_home')
where
  r1.year=2015
);

-- home advantage

-- Determined by:

-- 1) winning percentage
-- 2) head to head record
-- 3) record vs opposite conference

drop table if exists bbref.matrix_home;

create table bbref.matrix_home (
	year				integer,
	team_id				text,
	opponent_id			text,
	team_wp				float,
	opponent_wp			float,
	vs_won				integer,
	vs_lost				integer,
	team_ocwp			float,
	opponent_ocwp			float,
	home				boolean,
	primary key (year,team_id,opponent_id)
);

insert into bbref.matrix_home
(year,team_id,opponent_id)
(select
r1.year,
r1.team_id,
r2.team_id
from bbref.rounds r1
join bbref.rounds r2
  on ((r2.year)=(r1.year) and not((r2.team_id)=(r1.team_id)))
where
  r1.year=2015
);

create temporary table records (
       year	       integer,
       team_id	       text,
       won	       integer,
       lost	       integer,
       wp	       float,
       primary key (year,team_id)
);

insert into records
(year,team_id,won,lost,wp)
(
select
year,
team_id,
sum(won),
sum(lost),
sum(won::float)/count(*)
from
(

select
year,
home_id as team_id,
visitor_id as opponent_id,
(case when home_score>visitor_score then 1
      when home_score<visitor_score then 0
end) as won,
(case when home_score<visitor_score then 1
      when home_score>visitor_score then 0
end) as lost
from bbref.games
where year=2015

union all

select
year,
visitor_id as team_id,
home_id as opponent_id,
(case when home_score>visitor_score then 0
      when home_score<visitor_score then 1
end) as won,
(case when home_score<visitor_score then 0
      when home_score>visitor_score then 1
end) as lost
from bbref.games
where year=2015

) results
group by year,team_id
);

update bbref.matrix_home
set team_wp=r.wp
from records r
where
    r.year=matrix_home.year
and r.team_id=matrix_home.team_id;

update bbref.matrix_home
set opponent_wp=r.wp
from records r
where
    r.year=matrix_home.year
and r.team_id=matrix_home.opponent_id;

create temporary table vs (
       year				integer,
       team_id				text,
       team_conference_id		text,
       opponent_id			text,
       opponent_conference_id		text,
       won				integer,
       lost				integer,
       primary key (year, team_id, opponent_id)
);

insert into vs
(year,team_id,team_conference_id,opponent_id,opponent_conference_id,won,lost)
(
select
year,
team_id,
team_conference_id,
opponent_id,
opponent_conference_id,
sum(won),
sum(lost)
from
(

select
g.year,
g.home_id as team_id,
h.conference_id as team_conference_id,
g.visitor_id as opponent_id,
v.conference_id as opponent_conference_id,
(case when g.home_score > g.visitor_score then 1
      when g.home_score < g.visitor_score then 0
end) as won,
(case when g.home_score < g.visitor_score then 1
      when g.home_score> g.visitor_score then 0
end) as lost
from bbref.games g
join bbref.conferences h
  on (h.year,h.team_id)=(g.year,g.home_id)
join bbref.conferences v
  on (v.year,v.team_id)=(g.year,g.visitor_id)
where g.year=2015

union all

select

g.year,
g.visitor_id as team_id,
v.conference_id as team_conference_id,
g.home_id as opponent_id,
h.conference_id as opponent_conference_id,
(case when g.home_score > g.visitor_score then 0
      when g.home_score < g.visitor_score then 1
end) as won,

(case when g.home_score < g.visitor_score then 0
      when g.home_score > g.visitor_score then 1
end) as lost
from bbref.games g
join bbref.conferences h
  on (h.year,h.team_id)=(g.year,g.home_id)
join bbref.conferences v
  on (v.year,v.team_id)=(g.year,g.visitor_id)
where g.year=2015

) results
group by year,team_id,team_conference_id,opponent_id,opponent_conference_id
);

update bbref.matrix_home
set vs_won=vs.won,
    vs_lost=vs.lost
from vs
where
    vs.year=matrix_home.year
and vs.team_id=matrix_home.team_id
and vs.opponent_id=matrix_home.opponent_id;

update bbref.matrix_home
set team_ocwp=ocwp
from
(
select
year as year,
team_id as team_id,
sum(won::float)/sum(won+lost) as ocwp
from vs
where not(vs.team_conference_id=vs.opponent_conference_id)
group by year,team_id
) r
where (r.year,r.team_id)=(matrix_home.year,matrix_home.team_id);

update bbref.matrix_home
set opponent_ocwp=ocwp
from
(
select
year as year,
team_id as team_id,
sum(won::float)/sum(won+lost) as ocwp
from vs
where not(vs.team_conference_id=vs.opponent_conference_id)
group by year,team_id
) r
where (r.year,r.team_id)=(matrix_home.year,matrix_home.opponent_id);

update bbref.matrix_home
set home=
(case when team_wp > opponent_wp then true
      when team_wp = opponent_wp and vs_won > vs_lost then true
      when team_wp = opponent_wp and vs_won = vs_lost
           and team_ocwp > opponent_ocwp then true
      when team_wp < opponent_wp then false
      when team_wp = opponent_wp and vs_won < vs_lost then false
      when team_wp = opponent_wp and vs_won = vs_lost
           and team_ocwp < opponent_ocwp then false
end);

commit;
