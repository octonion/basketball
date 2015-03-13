select

r.year,

(sum(
case when ((t.strength)>(o.strength)
            and r.team_score>r.opponent_score) then 1
     when ((t.strength)<(o.strength)
            and r.team_score<r.opponent_score) then 1

else 0 end)::float/
count(*))::numeric(4,3) as model,

(
sum(
case when r.team_score>r.opponent_score and r.field='offense_home' then 1
     when r.team_score<r.opponent_score and r.field='defense_home' then 1
     when r.field='none' then 0.5
     else 0 end)::float/

count(*)

)::numeric(4,3) as naive,

(
sum(
case when ((t.strength)>(o.strength)
            and r.team_score>r.opponent_score) then 1
     when ((t.strength)<(o.strength)
            and r.team_score<r.opponent_score) then 1
else 0
end)::float/
count(*)

-

sum(
case when r.team_score>r.opponent_score and r.field='offense_home' then 1
     when r.team_score<r.opponent_score and r.field='defense_home' then 1
     when r.field='none' then 0.5
     else 0 end)::float/

count(*)
)::numeric(4,3) as diff,
count(*)
from euro.results r
join euro._schedule_factors t
  on (t.year,t.team_id)=(r.year,r.team_id)
join euro._schedule_factors o
  on (o.year,o.team_id)=(r.year,r.opponent_id)
join euro._factors f
  on (f.parameter,f.level)=('field',r.field)
where

TRUE

-- each game once

and r.team_id > r.opponent_id

-- test March and April

--and extract(month from r.game_date) in (3,4)

and r.team_score is not null
and r.opponent_score is not null

group by r.year
order by r.year;

select

(sum(
case when ((t.strength)>(o.strength)
            and r.team_score>r.opponent_score) then 1
     when ((t.strength)<(o.strength)
            and r.team_score<r.opponent_score) then 1
else 0 end)::float/
count(*))::numeric(4,3) as model,

(
sum(
case when r.team_score>r.opponent_score and r.field='offense_home' then 1
     when r.team_score<r.opponent_score and r.field='defense_home' then 1
     when r.field='none' then 0.5
     else 0 end)::float/
count(*)
)::numeric(4,3) as naive,

(
sum(
case when ((t.strength)>(o.strength)
            and r.team_score>r.opponent_score) then 1
     when ((t.strength)<(o.strength)
            and r.team_score<r.opponent_score) then 1
else 0
end)::float/
count(*)

-

sum(
case when r.team_score>r.opponent_score and r.field='offense_home' then 1
     when r.team_score<r.opponent_score and r.field='defense_home' then 1
     when r.field='none' then 0.5
     else 0 end)::float/
count(*)
)::numeric(4,3) as diff,
count(*)
from euro.results r
join euro._schedule_factors t
  on (t.year,t.team_id)=(r.year,r.team_id)
join euro._schedule_factors o
  on (o.year,o.team_id)=(r.year,r.opponent_id)
join euro._factors f
  on (f.parameter,f.level)=('field',r.field)
where

TRUE

-- each game once

and r.team_id > r.opponent_id

-- test March and April

--and extract(month from r.game_date) in (3,4)

and r.team_score is not null
and r.opponent_score is not null

;
