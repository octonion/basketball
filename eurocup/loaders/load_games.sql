begin;

drop table if exists eurocup.games;

create table eurocup.games (
	year		      integer,
	team_id		      text,
	game_number	      integer,
	result		      text,
	field		      text,
	opponent_name	      text,
	opponent_string	      text,
	game_url	      text,
	gamecode	      integer,
--	score		      text,
	home_score	      integer,
	away_score	      integer,
	game_date	      text,
--	game_date	      date
	unique (year, team_id, gamecode)
);

copy eurocup.games from '/tmp/games.csv' with delimiter as ',' csv quote as '"';

alter table eurocup.games add column game_id serial primary key;

commit;
