begin;

drop table if exists bbref.teams;

create table bbref.teams (
       team_id	  	  text,
       team_name	  text,
       primary key (team_id)
);

insert into bbref.teams
(team_id,team_name)
(
select
visitor_id,visitor_name
from bbref.games
where visitor_id is not null
and year>=1990
union
select
home_id,home_name
from bbref.games
where home_id is not null
and year>=1990
);

commit;
