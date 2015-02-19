begin;

create table bbref.playoffs (
	year				integer,
	game_date			text,
	date_url			text,
	boxscore			text,
	boxscore_url			text,
	visitor_name			text,
	visitor_url			text,
	visitor_score			integer,
	home_name			text,
	home_url			text,
	home_score			integer,
	status				text,
	notes				text
);

copy bbref.playoffs from '/tmp/bbref_playoffs.csv' with delimiter as ',' csv header quote as '"';

alter table bbref.playoffs
add column visitor_id text;

alter table bbref.playoffs
add column home_id text;

update bbref.playoffs
set visitor_id=split_part(visitor_url,'/',3);

update bbref.playoffs
set home_id=split_part(home_url,'/',3);

alter table bbref.playoffs add column game_id serial primary key;

commit;
