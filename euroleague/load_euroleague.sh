#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f create_schema_euroleague.sql

tail -q -n+2 csv/teams_*.csv > /tmp/teams.csv
psql basketball -f load_euroleague_teams.sql
rm /tmp/teams.csv

tail -q -n+2 csv/games_*.csv > /tmp/games.csv
psql basketball -f load_euroleague_games.sql
rm /tmp/games.csv
