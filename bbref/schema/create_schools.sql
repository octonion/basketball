begin;

drop table if exists bbref.schools;

create table bbref.schools (
       school_id	  text,
       school_name	  text,
       primary key (school_id)
);

insert into bbref.schools
(school_id,school_name)
(
select
distinct school_id,school_name
from bbref.draft_picks
where school_id is not null
);

commit;
