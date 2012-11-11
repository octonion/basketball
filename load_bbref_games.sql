begin;

create table bbref.games (
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

copy bbref.games from '/tmp/bbref_games.csv' with delimiter as ',' csv header quote as '"';

alter table bbref.games
add column visitor_id text;

alter table bbref.games
add column home_id text;

update bbref.games
set visitor_id=split_part(visitor_url,'/',3);

update bbref.games
set home_id=split_part(home_url,'/',3);

alter table bbref.games add column game_id serial primary key;

commit;
