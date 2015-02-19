begin;

create table ncaa_women.geocodes (
        school_name             text,
        school_id               integer,
	location		text,
        longitude		float,
	latitude		float,
	primary key (school_id)
);

copy ncaa_women.geocodes from '/tmp/ncaa_geocodes.csv' with delimiter as ',' csv quote as '"';

commit;
