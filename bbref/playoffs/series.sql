
select distinct home_id,visitor_id
from bbref.playoffs
where year=2016
and home_id<visitor_id;
