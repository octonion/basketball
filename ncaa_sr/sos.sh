#!/bin/bash

psql basketball -f sos/standardized_results.sql

psql basketball -c "drop table ncaa_sr._basic_factors;"
psql basketball -c "drop table ncaa_sr._parameter_levels;"
psql basketball -c "drop table ncaa_sr._factors;"
psql basketball -c "drop table ncaa_sr._schedule_factors;"

psql basketball -c "vacuum full verbose analyze ncaa_sr.results;"

R --vanilla -f sos/lmer.R

psql basketball -c "vacuum full verbose analyze ncaa_sr._basic_factors;"
psql basketball -c "vacuum full verbose analyze ncaa_sr._parameter_levels;"

psql basketball -f sos/normalize_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr._factors;"

psql basketball -f sos/schedule_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr._schedule_factors;"

psql basketball -f sos/current_ranking.sql > sos/current_ranking.txt

psql basketball -f sos/predict_daily.sql > sos/predict_daily.txt
cp /tmp/predict_daily.csv sos

psql basketball -f sos/predict_weekly.sql > sos/predict_weekly.txt
cp /tmp/predict_weekly.csv sos

#psql basketball -f sos/predict_uk.sql > sos/predict_uk.txt
#psql basketball -f sos/unlucky.sql > sos/unlucky.txt
