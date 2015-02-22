begin;

create table if not exists ncaa_sr.polls (
	year				integer,
	school_id			text,
	school_name			text,
	week				text,
	rank				integer,
	primary key (year,school_id,week)
);

copy ncaa_sr.polls from '/tmp/polls.csv' with delimiter as ',' csv header quote as '"';

commit;
