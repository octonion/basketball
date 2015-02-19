#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ]; then
   cmd="psql template1 -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f create_schema_bbref.sql

cp bbref/draft_picks.csv /tmp/bbref_draft_picks.csv
psql basketball -f load_bbref_draft_picks.sql
rm /tmp/bbref_draft_picks.csv

cp bbref/basic.csv /tmp/bbref_basic.csv
psql basketball -f load_bbref_basic.sql
rm /tmp/bbref_basic.csv

#psql basketball -f create_bbref_players.sql
psql basketball -f create_bbref_schools.sql

cat bbref/games*.csv >> /tmp/games.csv
psql basketball -f load_bbref_games.sql
rm /tmp/games.csv

psql basketball -f create_bbref_teams.sql

cp bbref/playoffs.csv /tmp/bbref_playoffs.csv
psql basketball -f load_bbref_playoffs.sql
rm /tmp/bbref_playoffs.csv

exit 0
