#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
   eval $cmd
fi

psql basketball -f schema/create_schema.sql

tail -q -n+2 csv/teams_*.csv > /tmp/teams.csv
psql basketball -f loaders/load_teams.sql
rm /tmp/teams.csv

tail -q -n+2 csv/games_*.csv > /tmp/games.csv
psql basketball -f loaders/load_games.sql
rm /tmp/games.csv
