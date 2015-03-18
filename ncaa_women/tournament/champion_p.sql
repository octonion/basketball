begin;

select
school_name,p::numeric(17,16)
from ncaa_women.rounds
where round_id=7
order by p desc;

copy
(
select
school_name,p::numeric(17,16)
from ncaa_women.rounds
where round_id=7
order by p desc
) to '/tmp/champion_p.csv' csv header;

commit;
