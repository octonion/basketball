begin;

drop table if exists ncaa_sr.rankings;

create table ncaa_sr.rankings (
	year				integer,
	ncaa_order			integer,
	octonion_rank			integer,
	octonion_order			integer,
	school_name			text,
	region_id			text,
	primary key (year,school_name)
);

copy ncaa_sr.rankings from '/tmp/rankings.csv' with delimiter as ',' csv header quote as '"';

commit;
