begin;

set timezone to 'America/Los_Angeles';

select

distinct

th.team_name as home,
--g.field as site,
tv.team_name as away,
(exp(i.estimate)*y.exp_factor*h.offensive*o.exp_factor*v.defensive)::numeric(4,1) as p_home,
(exp(i.estimate)*y.exp_factor*v.offensive*h.defensive*d.exp_factor)::numeric(4,1) as p_away
from euro.results g
join euro._schedule_factors h
  on (h.year,h.team_id)=(g.year,g.team_id)
join euro._schedule_factors v
  on (v.year,v.team_id)=(g.year,g.opponent_id)
join euro._factors o
  on (o.parameter,o.level)=('field','offense_home')
join euro._factors d
  on (d.parameter,d.level)=('field','defense_home')
join euro._factors y
  on (y.parameter,y.level)=('year',g.year::text)
join euro._basic_factors i
  on (i.factor)=('(Intercept)')

join euro.teams th
  on (th.year, th.team_id)=(g.year, g.team_id)
join euro.teams tv
  on (tv.year, tv.team_id)=(g.year, g.opponent_id)

where
    g.game_date is not null
--and g.game_date between current_date and current_date
and g.field='offense_home'

order by home asc;

commit;
