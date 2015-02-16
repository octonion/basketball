begin;

create table ncaa_sr.schools (
	row_number			integer,
	school_name			text,
	school_url			text,
	school_id			text,
	first_year			integer,
	last_year			integer,
	years				integer,
	games				integer,
	wins				integer,
	losses				integer,
	wl_pct				text,
	srs				float,
	sos				float,
	ap				integer,
	creg				integer,
	ctrn				integer,
	ncaa				integer,
	ff				integer,
	nc				integer,
	primary key (school_id)
);

copy ncaa_sr.schools from '/tmp/schools.csv' with delimiter as ',' csv header quote as '"';

commit;
