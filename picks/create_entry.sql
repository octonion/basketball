copy
(
select
'2015_'||r1.id::text||'_'||r2.id as id,
r1.strength/(r1.strength+r2.strength) as pred
from picks.ranks r1
join picks.ranks r2
  on (r1.id < r2.id)
order by r1.id asc, r2.id asc
) to '/tmp/bracketeers.csv' csv header;
