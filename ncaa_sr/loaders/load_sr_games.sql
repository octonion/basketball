begin;

drop table if exists ncaa_sr.games;

create table ncaa_sr.games (
	year				integer,
	school_id			text,
	school_name			text,
	row_number			integer,
	game_date			date,
	game_date_url			text,
	game_time			text,
	network				text,
	type				text,
	location			text,
	opponent			text,
	opponent_url			text,
	opponent_id			text,
	conference			text,
	conference_url			text,
	conference_id			text,
	outcome				text,
	team_score			integer,
	opponent_score			integer,
	ot				text,
	wins				integer,
	losses				integer,
	streak				text,
	arena				text,
	unique (year,school_id,row_number)
);

copy ncaa_sr.games from '/tmp/games.csv' with delimiter as ',' csv header;

--alter table ncaa_sr.games
--add column visitor_id text;

--alter table ncaa_sr.games
--add column home_id text;

--update ncaa_sr.games
--set visitor_id=split_part(visitor_url,'/',3);

--update ncaa_sr.games
--set home_id=split_part(home_url,'/',3);

--update ncaa_sr.games
--set status=''
--where status is null;

--update ncaa_sr.games
--set status='1OT'
--where status='OT';

alter table ncaa_sr.games add column game_id serial primary key;

commit;
