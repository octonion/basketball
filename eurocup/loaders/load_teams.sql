begin;

drop table if exists eurocup.teams;

create table eurocup.teams (
	year		      integer,
	team_id		      text,
	team_name	      text,
	team_url	      text,
	primary key (year,team_id),
	unique (year,team_name)
);

copy eurocup.teams from '/tmp/teams.csv' with delimiter as ',' csv quote as '"';

commit;
