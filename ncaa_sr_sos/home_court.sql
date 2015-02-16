select
split_part(o.level,'/',1) as team,
(o.exp_factor/d.exp_factor)::numeric(4,3) as home
from ncaa_sr._factors o
join ncaa_sr._factors d
  on (split_part(d.level,'/',1),split_part(d.level,'/',2))=
     (split_part(o.level,'/',1),'defense_home')
where o.parameter='team_field'
and split_part(o.level,'/',2)='offense_home'
order by home desc;

select split_part(o.level,'/',1) as team,(o.exp_factor)::numeric(4,3) as HCA_offense,(d.exp_factor)::numeric(4,3) as HCA_defense from ncaa_sr._factors o join ncaa_sr._factors d on (split_part(d.level,'/',1),split_part(d.level,'/',2))=(split_part(o.level,'/',1),'defense_home') where o.parameter='team_field' and o.level like '%offense%' order by team asc;