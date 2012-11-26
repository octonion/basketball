create schema si_json;

drop table if exists si_json.games;

create table si_json.games (
       day		     date,
       id		     integer,
       recap		     json,
       boxscore		     json,
       play_by_play	     json
);

copy si_json.games from '/home/clong/basketball/si/games_2013.csv' csv;

