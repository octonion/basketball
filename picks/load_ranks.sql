begin;

create schema if not exists picks;

drop table if exists picks.ranks;

create table picks.ranks (
	rank			integer,
	id			integer,
	team_name		text,
	ability			float,
	strength		float,
	primary key (id),
	unique (rank)
);

copy picks.ranks from '/tmp/ranks.csv' with delimiter as ',' csv header;

commit;
