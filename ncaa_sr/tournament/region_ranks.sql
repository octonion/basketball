select
region_id as region,
(exp(avg(log(ncaa_order::float))))::numeric(3,2) as ncaa_ao,
(exp(avg(log(octonion_order::float))))::numeric(3,2) as octonion_ao,
(exp(avg(log(octonion_rank::float))))::numeric(3,2) as octonion_ar,
avg(ncaa_order::float)::numeric(3,1) as ncaa_ho,
avg(octonion_order::float)::numeric(3,1) as octo_ho,
avg(octonion_rank::float)::numeric(3,1) as octo_hr
from ncaa_sr.rankings
where ncaa_order not in (44,46,66,68)
group by region
order by region;

select
region_id as region,
(exp(avg(log(ncaa_order::float))))::numeric(3,2) as ncaa_ao,
(exp(avg(log(octonion_order::float))))::numeric(3,2) as octonion_ao,
(exp(avg(log(octonion_rank::float))))::numeric(3,2) as octonion_ar,
avg(ncaa_order::float)::numeric(3,1) as ncaa_ho,
avg(octonion_order::float)::numeric(3,1) as octo_ho,
avg(octonion_rank::float)::numeric(3,1) as octo_hr
from ncaa_sr.rankings
where
    ncaa_order > 5
and ncaa_order not in (44,46,66,68)
group by region
order by region;

