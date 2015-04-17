begin;

drop table if exists bbref.conferences;

create table bbref.conferences (
       year		  integer,
       team_id	  	  text,
       conference_id	  text,
       primary key (year, team_id)
);

insert into bbref.conferences
(year, team_id, conference_id)
(
select
year, team_id, conference_id
from bbref.standings
);

commit;
