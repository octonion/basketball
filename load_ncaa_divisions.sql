begin;

create table ncaa.schools_divisions (
	sport_code		text,
	school_name		text,
	school_id		integer,
	pulled_name		text,
	javascript		text,
	year			integer,
	div_id			integer,
        school_year		text,
	sport			text,
	division		text,
	primary key (school_id,year)
);

copy ncaa.schools_divisions from '/tmp/ncaa_divisions.csv' with delimiter as ',' csv quote as '"';

/*
create table ncaa.schools_divisions (
	school_id		integer,
	division		text,
	primary key (school_id)
);

copy ncaa.schools_divisions from '/tmp/ncaa_schools_divisions.csv' with delimiter as ',' csv header quote as '"';

alter table ncaa.schools_divisions add column div_id integer;

update ncaa.schools_divisions
set div_id=length(division);
*/

commit;
