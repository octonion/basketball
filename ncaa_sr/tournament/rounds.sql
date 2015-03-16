begin;

drop table if exists ncaa_sr.rounds;

create table ncaa_sr.rounds (
       year		    integer,
       round_id		    integer,
       school_id	    text,
       school_name	    text,
       r1_id		    integer,
       r2_id		    integer,
       r3_id		    integer,
       r4_id		    integer,
       r5_id		    integer,
       r6_id		    integer,
       r7_id		    integer,
       p		    float,
       primary key (year,round_id,school_id)
);

insert into ncaa_sr.rounds
(year,round_id,school_id,school_name,
r1_id,r2_id,r3_id,r4_id,r5_id,r6_id,r7_id,
p)
(
select
b1.year as year,
1 as round_id,
s1.school_id,
b1.school_name,
b1.r1_id,
b1.r2_id,
b1.r3_id,
b1.r4_id,
b1.r5_id,
b1.r6_id,
b1.r7_id,
coalesce(
sf1.strength^10.25/
(sf1.strength^10.25+sf2.strength^10.25),1.0) as p

from ncaa_sr.brackets b1
left join ncaa_sr.brackets b2
  on ((b2.year,b2.r1_id)=(b1.year,b1.r1_id)
      and not(b1.school_id=b2.school_id))
left join ncaa_sr.schools s1
  on (s1.row_number)=(b1.school_id)
left join ncaa_sr.schools s2
  on (s2.row_number)=(b2.school_id)
left join ncaa_sr._schedule_factors sf1
  on (sf1.year,sf1.team_id)=(b1.year,s1.school_id)
left join ncaa_sr._schedule_factors sf2
  on (sf2.year,sf2.team_id)=(b2.year,s2.school_id)
and b1.year=2015
order by b1.r1_id,b1.r2_id,b1.r3_id,b1.r4_id
);

commit;


 

