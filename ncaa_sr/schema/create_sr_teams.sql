begin;

create table bbref.teams (
       team_id	  	  text,
       team_name	  text,
       primary key (team_id)
);

insert into bbref.teams
(team_id,team_name)
(
select
distinct visitor_id,visitor_name
from bbref.games
where visitor_id is not null
union
select
distinct home_id,home_name
from bbref.games
where home_id is not null
);

commit;
