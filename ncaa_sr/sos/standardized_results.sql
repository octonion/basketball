begin;

drop table if exists ncaa_sr.results;

create table ncaa_sr.results (
	game_id		      integer,
	year		      integer,
	game_date	      date,
	type		      text,
	team_name	      text,
	team_id		      text,
	opponent_name	      text,
	opponent_id	      text,
	location_id	      text,
	field		      text,
	team_score	      integer,
	opponent_score	      integer,
	game_length	      text,
	shot_clock	      text
);

insert into ncaa_sr.results
(game_id,year,
 game_date,type,
 team_name,team_id,
 opponent_name,opponent_id,
 location_id,field,
 team_score,opponent_score,
 game_length,shot_clock)
(
select
game_id,
year,
game_date,
type,
school_name,
school_id,
opponent,
opponent_id,
location as location_id,
(case when location is null then 'offense_home'
      when location='@' then 'defense_home'
      else 'neutral' end) as field,
team_score,
opponent_score,
ot as game_length,

(case when year=2015 and type in ('NIT','CIT','CBI') then '30 seconds'
      when year=2015 and type in ('NCAA','REG','CTOURN') then '35 seconds'
      when year between 1994 and 2014 then '35 seconds'
      when year between 1986 and 1993 then '45 seconds'
      when year between 1950 and 1985 then 'none'
end) as shot_clock
      
from ncaa_sr.games g
where
    g.team_score is not NULL
and g.opponent_score is not NULL
and g.team_score >= 0
and g.opponent_score >= 0
and g.school_id is not NULL
and g.opponent_id is not NULL
);

insert into ncaa_sr.results
(game_id,year,
 game_date,type,
 team_name,team_id,
 opponent_name,opponent_id,
 location_id,field,
 team_score,opponent_score,
 game_length,shot_clock)
(
select
game_id,
year,
game_date,
type,
opponent,
opponent_id,
school_name,
school_id,
location as location_id,
(case when location is null then 'defense_home'
      when location='@' then 'offense_home'
      else 'neutral' end) as field,
opponent_score,
team_score,
ot as game_length,

(case when year=2015 and type in ('NIT','CIT','CBI') then '30 seconds'
      when year=2015 and type in ('NCAA','REG','CTOURN') then '35 seconds'
      when year between 1994 and 2014 then '35 seconds'
      when year between 1986 and 1993 then '45 seconds'
      when year between 1950 and 1985 then 'none'
end) as shot_clock

from ncaa_sr.games g
where
    g.team_score is not NULL
and g.opponent_score is not NULL
and g.team_score >= 0
and g.opponent_score >= 0
and g.school_id is not NULL
and g.opponent_id is not NULL
);

update ncaa_sr.results
set game_length='1OT'
where game_length='OT';

update ncaa_sr.results
set game_length='0OT'
where game_length is null;

commit;
