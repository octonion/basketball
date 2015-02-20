
create or replace language plperlu;

--drop function distance_in_km (numeric,numeric,numeric,numeric);
--drop function distance_in_km (float,float,float,float);

create or replace function distance_in_km (float,float,float,float) returns float as
$body$
use strict;
use Math::Trig qw(great_circle_distance deg2rad);

my $lat1 = shift(@_);
my $lon1 = shift(@_);
my $lat2 = shift(@_);
my $lon2 = shift(@_);

# Notice the 90 - latitude: phi zero is at the North Pole.
sub NESW { deg2rad($_[0]), deg2rad(90 - $_[1]) }
my @L = NESW( $lat1, $lon1 );
my @T = NESW( $lat2, $lon2 );
my $km = great_circle_distance(@L, @T, 6378);

return $km;
$body$
language plperlu strict security definer;
