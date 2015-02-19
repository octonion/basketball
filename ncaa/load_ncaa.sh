#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'rockets';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database rockets\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb rockets"
   eval $cmd
fi

psql rockets -f create_schema_ncaa.sql

tail -q -n+2 ncaa/ncaa_games_*[0-9].csv > /tmp/ncaa_games.csv
chmod 644 /tmp/ncaa_games.csv
psql rockets -f load_ncaa_games.sql
rm /tmp/ncaa_games.csv

cat ncaa/ncaa_players_*.csv > /tmp/ncaa_statistics.csv
chmod 644 /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv
rpl ".0," "," /tmp/ncaa_statistics.csv
rpl ".00," "," /tmp/ncaa_statistics.csv
rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
psql rockets -f load_ncaa_statistics.sql
rm /tmp/ncaa_statistics.csv

psql rockets -f create_ncaa_players.sql

cp ncaa/ncaa_schools.csv /tmp/ncaa_schools.csv
chmod 644 /tmp/ncaa_schools.csv
psql rockets -f load_ncaa_schools.sql
rm /tmp/ncaa_schools.csv

cp ncaa/ncaa_divisions.csv /tmp/ncaa_divisions.csv
chmod 644 /tmp/ncaa_divisions.csv
psql rockets -f load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv

#cp ncaa/schools_divisions.csv /tmp/ncaa_schools_divisions.csv
#psql rockets -f load_ncaa_divisions.sql
#rm /tmp/ncaa_schools_divisions.csv

cp ncaa/ncaa_colors.csv /tmp/ncaa_colors.csv
chmod 644 /tmp/ncaa_colors.csv
psql rockets -f load_ncaa_colors.sql
rm /tmp/ncaa_colors.csv

cp ncaa/ncaa_geocodes.csv /tmp/ncaa_geocodes.csv
chmod 644 /tmp/ncaa_geocodes.csv
psql rockets -f load_ncaa_geocodes.sql
rm /tmp/ncaa_geocodes.csv

exit 0
