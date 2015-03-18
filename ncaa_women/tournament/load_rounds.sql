begin;

drop table if exists ncaa_women.rounds;

create table ncaa_women.rounds (
	year				integer,
	round_id			integer,
	school_id			integer,
	school_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,school_id)
);

copy ncaa_women.rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

commit;
