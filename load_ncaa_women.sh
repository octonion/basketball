#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f create_schema_ncaa_women.sql

tail -q -n+2 ncaa_women/ncaa_games_*.csv > /tmp/ncaa_games.csv
psql basketball -f load_ncaa_women_games.sql
rm /tmp/ncaa_games.csv

cat ncaa_women/ncaa_players_*.csv > /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv
rpl ".0," "," /tmp/ncaa_statistics.csv
rpl ".00," "," /tmp/ncaa_statistics.csv
rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
psql basketball -f load_ncaa_women_statistics.sql
rm /tmp/ncaa_statistics.csv

psql basketball -f create_ncaa_women_players.sql

cp ncaa_women/ncaa_schools.csv /tmp/ncaa_schools.csv
psql basketball -f load_ncaa_women_schools.sql
rm /tmp/ncaa_schools.csv

cp ncaa_women/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql basketball -f load_ncaa_women_divisions.sql
rm /tmp/ncaa_divisions.csv

#cp ncaa_women/schools_divisions.csv /tmp/ncaa_schools_divisions.csv
#psql basketball -f load_ncaa_divisions.sql
#rm /tmp/ncaa_schools_divisions.csv

cp ncaa_women/ncaa_colors.csv /tmp/ncaa_colors.csv
psql basketball -f load_ncaa_women_colors.sql
rm /tmp/ncaa_colors.csv

cp ncaa_women/ncaa_geocodes.csv /tmp/ncaa_geocodes.csv
psql basketball -f load_ncaa_women_geocodes.sql
rm /tmp/ncaa_geocodes.csv

exit 0
