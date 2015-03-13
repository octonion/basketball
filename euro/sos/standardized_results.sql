begin;

drop table if exists euro.results;

create table euro.results (
	game_id		      integer,
	year		      integer,
	team_id	      	      text,
	opponent_id	      text,
	location_id	      text,
	field		      text,
	team_score	      integer,
	opponent_score	      integer,
	game_length	      text
);

insert into euro.results
(game_id, year,
 team_id, opponent_id,
 location_id, field,
 team_score, opponent_score, game_length)
(
select
*
from eurocup.results
where
year between 2013 and 2014

union all

select
*
from euroleague.results
where
year between 2013 and 2014
);

commit;
