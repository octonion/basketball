#!/bin/bash

psql basketball -f ncaa_women_sos/standardized_results.sql

psql basketball -c "drop table if exists ncaa_women._basic_factors;"
psql basketball -c "drop table if exists ncaa_women._parameter_levels;"

psql basketball -c "vacuum analyze ncaa_women.results;"

R --vanilla < ncaa_women_sos/ncaa_lmer.R

psql basketball -f ncaa_women_sos/normalize_factors.sql
psql basketball -f ncaa_women_sos/schedule_factors.sql

psql basketball -f ncaa_women_sos/connectivity.sql > ncaa_women_sos/connectivity.txt
psql basketball -f ncaa_women_sos/current_ranking.sql > ncaa_women_sos/current_ranking.txt
psql basketball -f ncaa_women_sos/division_ranking.sql > ncaa_women_sos/division_ranking.txt

psql basketball -f ncaa_women_sos/test_predictions.sql > ncaa_women_sos/test_predictions.txt

psql basketball -f ncaa_women_sos/predict_daily.sql > ncaa_women_sos/predict_daily.txt
