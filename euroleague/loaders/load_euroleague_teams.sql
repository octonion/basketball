begin;

drop table if exists euroleague.teams;

create table euroleague.teams (
	year		      integer,
	team_id		      text,
	team_name	      text,
	team_url	      text,
	primary key (year,team_id),
	unique (year,team_name)
);

copy euroleague.teams from '/tmp/teams.csv' with delimiter as ',' csv quote as '"';

commit;
