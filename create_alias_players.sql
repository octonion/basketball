begin;

create table alias.players (
       bbref_id		   text references bbref.players (player_id),
       bbref_name	   text,
       ncaa_id		   integer references ncaa.players (player_id),
       ncaa_name	   text,
       primary key (bbref_id),
       unique (ncaa_id)
);

insert into alias.players
(
select
b.player_id,b.player_name,
n.player_id,n.player_name
from bbref.players b
join alias.schools s
  on (s.bbref_id)=(b.school_id)
join ncaa.players n
  on (n.school_id,n.name_last)=(s.ncaa_id,b.name_last)
where
b.player_id in
(
select
b.player_id
from bbref.players b
join alias.schools s
  on (s.bbref_id)=(b.school_id)
join ncaa.players n
  on (n.school_id,n.name_last)=(s.ncaa_id,b.name_last)
group by b.player_id
having count(*)=1
)
and
n.player_id in
(
select
n.player_id
from bbref.players b
join alias.schools s
  on (s.bbref_id)=(b.school_id)
join ncaa.players n
  on (n.school_id,n.name_last)=(s.ncaa_id,b.name_last)
group by n.player_id
having count(*)=1
)

);

commit;
