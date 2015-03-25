begin;

create temporary table years (
       first_year      integer,
       last_year       integer
);

insert into years
(first_year,last_year)
(select min(level::integer),max(level::integer)
from ncaa_sr.beta_parameter_levels
where parameter='year'
);

drop table if exists ncaa_sr.beta_factors;

create table ncaa_sr.beta_factors (
       parameter		text,
       level			text,
       type			text,
       method			text,
       year			integer,
       first_year		integer,
       last_year		integer,
       raw_factor		float,
       exp_factor		float,
       factor			float
--       primary key (team_name,type,method,year,first_year,last_year)
);

-- this can/should be rewritten agnostically
-- do random/fixed separately
-- test for the prescence of '/' using like

-- Random factors

-- defense,offense

insert into ncaa_sr.beta_factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
split_part(npl.level,'/',2) as level,
npl.type as type,
'log_regression' as method,
split_part(npl.level,'/',1)::integer as year,
split_part(npl.level,'/',1)::integer as first_year,
split_part(npl.level,'/',1)::integer as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from ncaa_sr.beta_parameter_levels npl
left outer join ncaa_sr.beta_basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter in ('defense','offense')
);

-- other random

insert into ncaa_sr.beta_factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
estimate as raw_factor,
null as exp_factor
--exp(estimate) as exp_factor
from ncaa_sr.beta_parameter_levels npl
left outer join ncaa_sr.beta_basic_factors nbf
  on (nbf.factor,nbf.level,nbf.type)=(npl.parameter,npl.level,npl.type)
where
    npl.type='random'
and npl.parameter not in ('defense','offense')
);

-- Fixed factors

-- year

insert into ncaa_sr.beta_factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
npl.level::integer as year,
npl.level::integer as first_year,
npl.level::integer as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
--coalesce(exp(estimate),1.0) as exp_factor
from ncaa_sr.beta_parameter_levels npl
left outer join ncaa_sr.beta_basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('year')
);

-- field

insert into ncaa_sr.beta_factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
from ncaa_sr.beta_parameter_levels npl
left outer join ncaa_sr.beta_basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter in ('field')
and npl.level not in ('neutral')
);

-- other fixed

insert into ncaa_sr.beta_factors
(parameter,level,type,method,year,first_year,last_year,raw_factor,exp_factor)
(
select
npl.parameter as parameter,
npl.level as level,
npl.type as type,
'log_regression' as method,
null as year,
null as first_year,
null as last_year,
coalesce(estimate,0.0) as raw_factor,
null as exp_factor
from ncaa_sr.beta_parameter_levels npl
left outer join ncaa_sr.beta_basic_factors nbf
  on (nbf.factor,nbf.type)=(npl.parameter||npl.level,npl.type)
where
    npl.type='fixed'
and npl.parameter not in ('field','year')
);

update ncaa_sr.beta_factors
set exp_factor=exp(raw_factor);

commit;
