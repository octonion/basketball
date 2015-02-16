select pl.parameter,pl.type,pl.level,bf.estimate
from ncaa_sr._parameter_levels pl
left outer join ncaa_sr._basic_factors bf
  on (bf.factor,bf.type)=(pl.parameter||pl.level,pl.type)
where pl.type='fixed'
order by parameter,level;
