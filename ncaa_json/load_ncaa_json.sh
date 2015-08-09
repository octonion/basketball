#!/bin/bash

cp csv/games_2015.csv /tmp/games_2015.csv
psql basketball -f load_ncaa_json.sql
rm /tmp/games_2015.csv
