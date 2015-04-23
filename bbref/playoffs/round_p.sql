begin;

select round_id as rd,
team_name as name,
p::numeric(4,3) as p
from bbref.rounds r
join bbref.teams t
 on (t.team_id)=(r.team_id)
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc;

copy
(
select round_id as rd,
team_name as name,
p::numeric(4,3) as p
from bbref.rounds r
join bbref.teams t
 on (t.team_id)=(r.team_id)
where TRUE --round_id=2
and p<1.0
order by round_id asc,p desc
)
to '/tmp/round_p.csv' csv header;

commit;
