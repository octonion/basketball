begin;

create table ncaa_women.schools (
        school_id               integer,
        school_name             text,
	primary key (school_id)
);

copy ncaa_women.schools from '/tmp/ncaa_schools.csv' with delimiter as ',' csv;

commit;
