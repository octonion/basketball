begin;

create table ncaa.geocodes (
        school_name             text,
        school_id               integer,
	location		text,
        longitude		float,
	latitude		float,
	elevation		float,
	primary key (school_id)
);

copy ncaa.geocodes from '/tmp/ncaa_geocodes.csv' with delimiter as ',' csv quote as '"';

commit;
