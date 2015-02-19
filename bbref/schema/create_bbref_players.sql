begin;

create table bbref.players (
       player_id	  text,
       player_name	  text,
       name_last	  text,
       name_first	  text,
       draft_year	  integer,
       school_name	  text,
       school_id	  text,
       primary key (player_id)
);

insert into bbref.players
(player_id,player_name,name_last,name_first,draft_year,school_name,school_id)
(
select
distinct
player_id,
player_name,
split_part(player_name,' ',2),
split_part(player_name,' ',1),
year,
school_name,
school_id
from bbref.draft_picks
where
    player_id is not null
and school_id is not null
);

commit;
