#!/bin/bash

#cp rounds_2015.csv /tmp/rounds.csv
psql basketball -f load_rounds.sql
rm /tmp/rounds.csv

psql basketball -f update_round.sql

rpl "round_id=1" "round_id=2" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=2" "round_id=3" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=3" "round_id=4" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=4" "round_id=5" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=5" "round_id=6" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=6" "round_id=7" update_round.sql
psql basketball -f update_round.sql

rpl "round_id=7" "round_id=1" update_round.sql

psql basketball -f round_p.sql > round_p.txt
cp /tmp/round_p.csv .

psql basketball -f champion_p.sql > champion_p.txt
cp /tmp/champion_p.csv .
