begin;

select
team_name,p::numeric(4,3)
from bbref.rounds r
join bbref.teams t
  on (t.team_id)=(r.team_id)
where round_id=5
order by p desc;

copy
(
select
team_name,p::numeric(4,3)
from bbref.rounds r
join bbref.teams t
  on (t.team_id)=(r.team_id)
where round_id=5
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
