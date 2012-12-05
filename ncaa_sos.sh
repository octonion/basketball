#!/bin/bash

psql basketball -f ncaa_sos/standardized_results.sql

psql basketball -c "drop table ncaa._basic_factors;"
psql basketball -c "drop table ncaa._parameter_levels;"

#psql basketball -c "drop table ncaa._factors;"
#psql basketball -c "drop table ncaa._schedule_factors;"
##psql basketball -c "drop table ncaa._game_results;"

psql basketball -c "vacuum analyze ncaa.results;"

R --vanilla < ncaa_sos/ncaa_lmer.R

psql basketball -f ncaa_sos/normalize_factors.sql
psql basketball -f ncaa_sos/schedule_factors.sql

psql basketball -f ncaa_sos/connectivity.sql > ncaa_sos/connectivity.txt
psql basketball -f ncaa_sos/current_ranking.sql > ncaa_sos/current_ranking.txt
psql basketball -f ncaa_sos/division_ranking.sql > ncaa_sos/division_ranking.txt

psql basketball -f ncaa_sos/test_predictions.sql > ncaa_sos/test_predictions.txt

psql basketball -f ncaa_sos/predict_daily.sql > ncaa_sos/predict_daily.txt
