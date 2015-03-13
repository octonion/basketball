begin;

create schema if not exists euro;

drop table if exists euro.teams;

create table euro.teams (
	year		      integer,
	team_id		      text,
	team_name	      text,
--	team_url	      text,
	primary key (year,team_id),
	unique (year,team_name)
);

insert into euro.teams
(year,team_id,team_name)
(
select
year,team_id,team_name
from eurocup.teams

union

select
year,team_id,team_name
from euroleague.teams
);

commit;
