#!/bin/bash

cp CSV/games_2014.csv /tmp/games_2014.csv
psql basketball -f load_ncaa_json.sql
rm /tmp/games_2014.csv
