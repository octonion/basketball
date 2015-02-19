#!/bin/bash

#psql basketball -f standardized_results.sql

psql basketball -c "drop table ncaa._basic_factors;"
psql basketball -c "drop table ncaa._parameter_levels;"
#psql basketball -c "drop table ncaa._factors;"
#psql basketball -c "drop table ncaa._schedule_factors;"
##psql basketball -c "drop table ncaa._game_results;"

R --vanilla < ncaa_lmer_geocoding.R

psql basketball -f normalize_factors.sql
psql basketball -f schedule_factors.sql

psql basketball -f connectivity.sql > connectivity.txt
psql basketball -f current_ranking.sql > current_ranking.txt
psql basketball -f division_ranking.sql > division_ranking.txt

psql basketball -f test_predictions.sql > test_predictions.txt
