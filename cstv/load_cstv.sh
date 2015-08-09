#!/bin/bash

cmd="psql --tuples-only --command \"select count(*) from pg_database where datname = 'basketball';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="psql -t -c \"create database basketball\" > /dev/null 2>&1"
#   cmd="psql -t -c \"$sql\" > /dev/null 2>&1"
#   cmd="createdb basketball"
   eval $cmd
fi

psql basketball -f create_schema_cstv.sql

cp cstv/game.csv /tmp
psql basketball -f load_cstv_games.sql
rm /tmp/game.csv

cp cstv/play.csv /tmp
rpl -q '""' '' /tmp/play.csv
psql basketball -f load_cstv_plays.sql
rm /tmp/play.csv

exit 0
