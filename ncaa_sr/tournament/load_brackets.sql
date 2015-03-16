begin;

drop table if exists ncaa_sr.brackets;

create table ncaa_sr.brackets (
	year				integer,
	school_id			integer,
	school_name			text,
	r1_id				integer,
	r2_id				integer,
	r3_id				integer,
	r4_id				integer,
	r5_id				integer,
	r6_id				integer,
	r7_id				integer,
	primary key (year,school_id)
);

copy ncaa_sr.brackets from '/tmp/brackets.csv' with delimiter as ',' csv header quote as '"';

commit;
