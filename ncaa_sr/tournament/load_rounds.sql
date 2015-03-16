begin;

drop table if exists ncaa_sr.rounds;

create table ncaa_sr.rounds (
	year				integer,
	round_id			integer,
	school_id			text,
	school_name			text,
	bracket				int[],
	p				float,
	primary key (year,round_id,school_id)
);

copy ncaa_sr.rounds from '/tmp/rounds.csv' with delimiter as ',' csv header quote as '"';

commit;
