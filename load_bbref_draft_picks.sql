begin;

create table bbref.draft_picks (
	year				integer,
	pick		      		integer,
	team_id		      		text,
	team_url	      		text,
	player_name	      		text,
	player_url	      		text,
	school_name	      		text,
	school_url	      		text,
	games		      		integer,
	minutes_played	      		integer,
	points		      		integer,
	rebounds	      		integer,
	assists		      		integer,
	field_goal_percent 		float,
	three_point_percent		float,
	free_throw_percent		float,
	minutes_per_game		float,
	points_per_game			float,
	rebounds_per_game		float,
	assists_per_game		float,
	win_shares			float,
	win_shares_48			float
);

copy bbref.draft_picks from '/tmp/bbref_draft_picks.csv' with delimiter as ',' csv header quote as '"';

alter table bbref.draft_picks
add column player_id text;

alter table bbref.draft_picks
add column school_id text;

update bbref.draft_picks
set player_id=split_part(split_part(player_url,'/',4),'.',1);

update bbref.draft_picks
set school_id=split_part(school_url,'=',2);

commit;
