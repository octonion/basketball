#!/bin/bash

cmd="psql --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f create_schema_ncaa.sql

tail -q -n+2 ncaa/ncaa_games_*.csv > /tmp/ncaa_games.csv
psql basketball -f load_ncaa_games.sql
rm /tmp/ncaa_games.csv

cat ncaa/ncaa_players_*.csv > /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv
rpl ".0," "," /tmp/ncaa_statistics.csv
rpl ".00," "," /tmp/ncaa_statistics.csv
rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
psql basketball -f load_ncaa_statistics.sql
rm /tmp/ncaa_statistics.csv

psql basketball -f create_ncaa_players.sql

cp ncaa/ncaa_schools.csv /tmp/ncaa_schools.csv
psql basketball -f load_ncaa_schools.sql
rm /tmp/ncaa_schools.csv

cp ncaa/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql basketball -f load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv

#cp ncaa/schools_divisions.csv /tmp/ncaa_schools_divisions.csv
#psql basketball -f load_ncaa_divisions.sql
#rm /tmp/ncaa_schools_divisions.csv

cp ncaa/ncaa_colors.csv /tmp/ncaa_colors.csv
psql basketball -f load_ncaa_colors.sql
rm /tmp/ncaa_colors.csv

cp ncaa/ncaa_geocodes.csv /tmp/ncaa_geocodes.csv
psql basketball -f load_ncaa_geocodes.sql
rm /tmp/ncaa_geocodes.csv

exit 1
