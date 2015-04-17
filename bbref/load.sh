#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ]; then
#   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f schema/create_schema.sql

cp csv/draft_picks.csv /tmp/draft_picks.csv
psql basketball -f loaders/load_draft_picks.sql
rm /tmp/draft_picks.csv

cp csv/basic.csv /tmp/basic.csv
psql basketball -f loaders/load_basic.sql
rm /tmp/basic.csv

psql basketball -f schema/create_players.sql
psql basketball -f schema/create_schools.sql

cat csv/games*.csv >> /tmp/games.csv
psql basketball -f loaders/load_games.sql
rm /tmp/games.csv

psql basketball -f schema/create_teams.sql

cat csv/playoffs*.csv >> /tmp/playoffs.csv
psql basketball -f loaders/load_playoffs.sql
rm /tmp/playoffs.csv
