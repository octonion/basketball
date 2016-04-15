begin;

insert into bbref.rounds
(year,round_id,team_id,seed,bracket,p)
(
select
r1.year as year,
r1.round_id+1 as round,
r1.team_id,
r1.seed,
r1.bracket,

sum(
(case when r2.team_id is null then 1.0
 else
r1.p*r2.p*
(
case
when mh.home then
(
  mp1.home_p^4
+ 4*mp1.home_p^3*mp1.visitor_p^1*
    (1-mp2.home_p^3)
+ 6*mp1.home_p^2*mp1.visitor_p^2*
    (mp2.visitor_p^3+3*mp2.visitor_p^2*mp2.home_p^1)
+ 4*mp1.home_p^1*mp1.visitor_p^3*
    (mp2.visitor_p^3)
)

when not(mh.home) then
1.0-
(
  mp2.home_p^4
+ 4*mp2.home_p^3*mp2.visitor_p^1*
    (1-mp1.home_p^3)
+ 6*mp2.home_p^2*mp2.visitor_p^2*
    (mp1.visitor_p^3+3*mp1.visitor_p^2*mp1.home_p^1)
+ 4*mp2.home_p^1*mp2.visitor_p^3*
    (mp1.visitor_p^3)
)
end)
end)) as p

from bbref.rounds r1
left join bbref.rounds r2
  on ((r1.year,r1.round_id,r1.bracket[r1.round_id+1])=
      (r2.year,r2.round_id,r2.bracket[r1.round_id+1])
       and not(r1.bracket[r1.round_id]=r2.bracket[r1.round_id]))
left join bbref.matrix_p mp1
  on (mp1.year,mp1.home_id,mp1.visitor_id)=(r1.year,r1.team_id,r2.team_id)
left join bbref.matrix_p mp2
  on (mp2.year,mp2.home_id,mp2.visitor_id)=(r2.year,r2.team_id,r1.team_id)
left join bbref.matrix_home mh
  on (mh.year,mh.team_id,mh.opponent_id)=(r1.year,r1.team_id,r2.team_id)
where
    r1.year=2016
and r1.round_id=1
group by r1.year,round,r1.team_id,r1.seed,r1.bracket
);

commit;
