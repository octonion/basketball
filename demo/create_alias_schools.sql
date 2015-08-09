begin;

create table alias.schools (
       bbref_id		   text references bbref.schools (school_id),
       bbref_name	   text,
       ncaa_id		   integer references ncaa.schools (school_id),
       ncaa_name	   text,
       primary key (bbref_id),
       unique (ncaa_id)
);

create temporary table d (
       bbref_id	       text,
       bbref_name      text,
       d	       integer
);

insert into d
(bbref_id,bbref_name,d)
(
select
b.school_id,
b.school_name,
min(
levenshtein(
b.school_id,
replace(replace(lower(n.school_name),' ',''),'.',''))
)
as d
from bbref.schools b,ncaa.schools n
group by b.school_id,b.school_name
);

insert into alias.schools
(
select
d.bbref_id,d.bbref_name,
n.school_id,n.school_name
from d,ncaa.schools n
where
levenshtein(
d.bbref_id,
replace(replace(lower(n.school_name),' ',''),'.',''))
=d.d
and d.d=0
);

commit;
