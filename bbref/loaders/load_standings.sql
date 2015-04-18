begin;

drop table if exists bbref.standings;

create table bbref.standings (
	year				integer,
	conference_id			text,
	division_name			text,
	team_name			text,
	team_id				text,
	team_url			text,
	won				integer,
	lost				integer,
	wp				float,
	games_back			text,
	ps_g				float,
	pa_g				float,
	srs				float,
	primary key (year, team_id)
);

copy bbref.standings from '/tmp/standings.csv' with delimiter as ',' csv quote as '"';

commit;
