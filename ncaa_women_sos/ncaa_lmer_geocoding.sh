#!/bin/bash

#psql basketball -f standardized_results.sql

psql basketball -c "drop table ncaa_women._basic_factors;"
psql basketball -c "drop table ncaa_women._parameter_levels;"
#psql basketball -c "drop table ncaa_women._factors;"
#psql basketball -c "drop table ncaa_women._schedule_factors;"
##psql basketball -c "drop table ncaa_women._game_results;"

R --vanilla < ncaa_lmer_geocoding.R

psql basketball -f normalize_factors.sql
psql basketball -f schedule_factors.sql

psql basketball -f connectivity.sql > connectivity.txt
psql basketball -f current_ranking.sql > current_ranking.txt
psql basketball -f division_ranking.sql > division_ranking.txt

psql basketball -f test_predictions.sql > test_predictions.txt
