select
school_name,p::numeric(12,11)
from ncaa_sr.rounds
where round_id=8
order by p desc;
