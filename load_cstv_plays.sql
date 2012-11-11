begin;

drop table if exists cstv.plays;

create table cstv.plays (
        event_id	      integer,
	period_number	      integer,
	vh		      text,
	time		      interval,
	uni		      text,
	team		      text,
	checkname	      text,
	action		      text,
	type		      text,
	paint		      boolean,
	vscore		      integer,
	hscore		      integer,
	play_id	      	      integer,
	primary key (event_id,play_id)
);

copy cstv.plays from '/tmp/play.csv' with delimiter as ',' csv header quote as '"';

--alter table ncaa.games add column game_id serial primary key;

commit;
