begin;

create schema if not exists picks;

drop table if exists picks.teams;

create table picks.teams (
	id			integer,
	seed			integer,
	name_short		text,
	name_long		text,
	eid			integer,
	k_id			integer,
	primary key (id),
	unique (eid),
	unique (k_id)
);

copy picks.teams from '/tmp/teams.csv' with delimiter as ',' csv header;

commit;
