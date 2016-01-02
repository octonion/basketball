begin;

drop table if exists bbref.games;

create table bbref.games (
	year				integer,
	game_date			text,
	date_url			text,
	game_time			text,
	boxscore			text,
	boxscore_url			text,
	visitor_name			text,
	visitor_url			text,
	visitor_id			text,
	visitor_score			integer,
	home_name			text,
	home_url			text,
	home_id				text,
	home_score			integer,
	status				text,
	notes				text
);

copy bbref.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

--alter table bbref.games
--add column visitor_id text;

--alter table bbref.games
--add column home_id text;

--update bbref.games
--set visitor_id=split_part(visitor_url,'/',3);

--update bbref.games
--set home_id=split_part(home_url,'/',3);

update bbref.games
set status=''
where status is null;

update bbref.games
set status='1OT'
where status='OT';

alter table bbref.games add column game_id serial primary key;

commit;
