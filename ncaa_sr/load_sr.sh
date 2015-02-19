#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ]; then
   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
   eval $cmd
fi

psql basketball -f create_schema_sr.sql

cp csv/schools.csv /tmp/schools.csv
psql basketball -f load_sr_schools.sql
rm /tmp/schools.csv

cp csv/years.csv /tmp/years.csv
psql basketball -f load_sr_years.sql
rm /tmp/years.csv

cp csv/polls.csv /tmp/polls.csv
psql basketball -f load_sr_polls.sql
rm /tmp/polls.csv

cp csv/games.csv /tmp/games.csv
psql basketball -f load_sr_games.sql
rm /tmp/games.csv

cp csv/games_current.csv /tmp/games_current.csv
psql basketball -f load_sr_games_current.sql
rm /tmp/games_current.csv
