begin;

create table ncaa_sr.years (
	school_id			text,
	school_name			text,
	row_number			integer,
	year				integer,
	season				text,
	school_year_url			text,
	conference_name			text,
	conference_url			text,
	wins				integer,
	losses				integer,
	wl_pct				float,
	srs				float,
	sos				float,
	ppg				float,
	oppg				float,
	ap_pre				integer,
	ap_high				integer,
	ap_final			integer,
	ncaa_tournament			text,
	coach				text,
	coach_url			text,
	primary key (school_id,year)
);

copy ncaa_sr.years from '/tmp/years.csv' with delimiter as ',' csv header quote as '"';

commit;
