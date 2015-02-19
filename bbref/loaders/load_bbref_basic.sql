begin;

create table bbref.basic_statistics (
	year				integer,
	rank		      		integer,
	player_name	      		text,
	player_url	      		text,
	age				integer,
	team_id		      		text,
	team_url	      		text,
	games		      		integer,
	games_started			integer,
	minutes_played	      		integer,
	field_goals			integer,
	field_goal_attempts		integer,
	field_goal_percent 		float,
	three_pointers			integer,
	three_point_attempts		integer,
	three_point_percent		float,
	free_throws			integer,
	free_throw_attempts		integer,
	free_throw_percent		float,
	offensive_rebounds		integer,
	defensive_rebounds		integer,
	rebounds	      		integer,
	assists		      		integer,
	steals				integer,
	blocks				integer,
	turnovers			integer,
	personal_fouls			integer,
	points		      		integer
);

copy bbref.basic_statistics from '/tmp/bbref_basic.csv' with delimiter as ',' csv header quote as '"';

alter table bbref.basic_statistics
add column player_id text;

update bbref.basic_statistics
set player_id=split_part(split_part(player_url,'/',4),'.',1);

commit;
