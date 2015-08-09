#!/bin/bash

cd pbp
./pull_pbp.sh
cd ..

psql basketball -f create_schema_pbp.sql

tail -q -n+2 pbp/match*.txt > /tmp/matchups.csv
rpl -q "NULL" "" /tmp/matchups.csv
psql basketball -f load_pbp_matchups.sql
rm /tmp/matchups.csv

exit 1
