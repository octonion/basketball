#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`

if [ $db_exists -eq 0 ] ; then
   cmd="createdb basketball;"
   eval $cmd
fi

# Alias

psql basketball -f create_schema_alias.sql

# PostgreSQL fuzzy string mathcing extension

psql basketball -c "create extension fuzzystrmatch;"

# Basketball Reference data

psql basketball -f ../bbref/schema/create_schema.sql

# NBA draft picks

cp ../bbref/csv/draft_picks.csv /tmp/draft_picks.csv
psql basketball -f ../bbref/loaders/load_draft_picks.sql
rm /tmp/draft_picks.csv

# NBA basic statistics

cp ../bbref/csv/basic.csv /tmp/basic.csv
psql basketball -f ../bbref/loaders/load_basic.sql
rm /tmp/basic.csv

# NBA schools and players

psql basketball -f ../bbref/schema/create_schools.sql
psql basketball -f ../bbref/schema/create_players.sql

# NBA games

cat ../bbref/csv/games_1*.csv >> /tmp/games.csv
cat ../bbref/csv/games_2*.csv >> /tmp/games.csv
psql basketball -f ../bbref/loaders/load_games.sql
rm /tmp/games.csv

# NBA playoffs

cat ../bbref/csv/playoffs_*.csv >> /tmp/playoffs.csv
psql basketball -f ../bbref/loaders/load_playoffs.sql
rm /tmp/playoffs.csv

# NBA teams

psql basketball -f ../bbref/schema/create_teams.sql

# NCAA schema

psql basketball -f ../ncaa/schema/create_schema_ncaa.sql

# NCAA game results

tail -q -n+2 ../ncaa/csv/ncaa_games_*[0-9].csv > /tmp/ncaa_games.csv
psql basketball -f ../ncaa/loaders/load_ncaa_games.sql
rm /tmp/ncaa_games.csv

#tail -q -n+2 ../ncaa/csv/ncaa_games_*.csv > /tmp/ncaa_games.csv
#rpl -q '""' '' /tmp/ncaa_games.csv
#psql basketball -f ../ncaa/loaders/load_ncaa_games.sql
#rm /tmp/ncaa_games.csv

# NCAA players statistics

cat ../ncaa/csv/ncaa_players_200?.csv > /tmp/ncaa_statistics.csv
cat ../ncaa/csv/ncaa_players_201[01234].csv >> /tmp/ncaa_statistics.csv

rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv
rpl ".0," "," /tmp/ncaa_statistics.csv
rpl ".00," "," /tmp/ncaa_statistics.csv
rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv

psql basketball -f ../ncaa/loaders/load_ncaa_statistics.sql
rm /tmp/ncaa_statistics.csv

# NCAA players

psql basketball -f ../ncaa/schema/create_ncaa_players.sql

# NCAA schools

cp ../ncaa/csv/ncaa_schools.csv /tmp/ncaa_schools.csv
psql basketball -f ../ncaa/loaders/load_ncaa_schools.sql
rm /tmp/ncaa_schools.csv

# NCAA school divisions

cp ../ncaa/csv/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql basketball -f ../ncaa/loaders/load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv

# NCAA school colors

cp ../ncaa/csv/ncaa_colors.csv /tmp/ncaa_colors.csv
psql basketball -f ../ncaa/loaders/load_ncaa_colors.sql
rm /tmp/ncaa_colors.csv

# Aliases

psql basketball -f create_schema_alias.sql

# Match schools using Levenshtein distance (exact match for now)

psql basketball -f create_alias_schools.sql

# Matching players on school and last name

psql basketball -f create_alias_players.sql

# Basic feature detection for NCAA characteristics impacting NBA playing time 1 year out

R --vanilla < feature_selection.R
