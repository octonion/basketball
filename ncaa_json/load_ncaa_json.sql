begin;

drop schema if exists ncaa_json cascade;

create schema ncaa_json;

create table ncaa_json.games (
       game_id		     integer,
       game_date	     date,
       gameinfo		     jsonb,
       boxscore		     jsonb,
       pbp		     jsonb
-- Need to check primary key situation
--       primary key (game_id,game_date)
);

copy ncaa_json.games from '/tmp/games_2015.csv' csv;

commit;

