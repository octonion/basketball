begin;

create table ncaa.colors (
        school_name             text,
        school_id               integer,
        colors		      text,
	primary key (school_id)
);

copy ncaa.colors from '/tmp/ncaa_colors.csv' with delimiter as ',' csv quote as '"';

commit;
