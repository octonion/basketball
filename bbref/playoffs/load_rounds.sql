begin;

-- rounds

drop table if exists bbref.rounds;

create table bbref.rounds (
	year				integer,
	round_id			integer,
	team_id				text,
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
(h.strength*o.exp_factor)^16.5/
((h.strength*o.exp_factor)^16.5+(v.strength*d.exp_factor)^16.5)
  as home_p,
(v.strength*d.exp_factor)^16.5/
((v.strength*d.exp_factor)^16.5+(h.strength*o.exp_factor)^16.5)
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

/*
drop table if exists bbref.matrix_home;

create table bbref.matrix_home (
	year				integer,
	team_id				text,
	opponent_id			text,
	team_wp				float,
	opponent_wp			float,
	home				boolean,
	primary key (year,home_id,visitor_id)
);
*/

commit;
