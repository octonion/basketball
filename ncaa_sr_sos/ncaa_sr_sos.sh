#!/bin/bash

psql basketball -f standardized_results.sql

psql basketball -c "drop table ncaa_sr._basic_factors;"
psql basketball -c "drop table ncaa_sr._parameter_levels;"
psql basketball -c "drop table ncaa_sr._factors;"
psql basketball -c "drop table ncaa_sr._schedule_factors;"

psql basketball -c "vacuum full verbose analyze ncaa_sr.results;"

R --vanilla < ncaa_sr_lmer.R

psql basketball -c "vacuum full verbose analyze ncaa_sr._basic_factors;"
psql basketball -c "vacuum full verbose analyze ncaa_sr._parameter_levels;"

psql basketball -f normalize_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr._factors;"

psql basketball -f schedule_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr._schedule_factors;"

psql basketball -f current_ranking.sql > current_ranking.txt

#psql basketball -f predict_playoffs.sql > ncaa_sr_sos/predict_playoffs.txt

#psql basketball -f predict_daily.sql > ncaa_sr_sos/predict_daily.txt

#psql basketball -f predict_spread.sql > ncaa_sr_sos/predict_spread.txt
