begin;

drop table if exists cstv.games;

create table cstv.games (
        event_id               integer,
	primary key (event_id)
);

copy cstv.games from '/tmp/game.csv' with delimiter as ',' csv header quote as '"';

--alter table ncaa.games add column game_id serial primary key;

commit;
