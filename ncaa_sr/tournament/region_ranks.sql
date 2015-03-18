select
region_id as region,
avg(ncaa_order::float)::numeric(3,1) as ncaa_ao,
avg(octonion_order::float)::numeric(3,1) as octo_ao,
avg(octonion_rank::float)::numeric(3,1) as octo_ar,
(exp(avg(log(ncaa_order::float))))::numeric(3,2) as ncaa_ho,
(exp(avg(log(octonion_order::float))))::numeric(3,2) as octonion_ho,
(exp(avg(log(octonion_rank::float))))::numeric(3,2) as octonion_hr
from ncaa_sr.rankings
where ncaa_order not in (44,46,66,68)
group by region
order by region;

select
region_id as region,
avg(ncaa_order::float)::numeric(3,1) as ncaa_ao,
avg(octonion_order::float)::numeric(3,1) as octo_ao,
avg(octonion_rank::float)::numeric(3,1) as octo_ar,
(exp(avg(log(ncaa_order::float))))::numeric(3,2) as ncaa_ho,
(exp(avg(log(octonion_order::float))))::numeric(3,2) as octonion_ho,
(exp(avg(log(octonion_rank::float))))::numeric(3,2) as octonion_hr
from ncaa_sr.rankings
where
    ncaa_order > 5
and ncaa_order not in (44,46,66,68)
group by region
order by region;

