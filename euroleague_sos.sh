#!/bin/bash

psql rockets -f euroleague_sos/standardized_results.sql

psql rockets -c "drop table euroleague._basic_factors;"
psql rockets -c "drop table euroleague._parameter_levels;"

psql rockets -c "vacuum analyze euroleague.results;"

R --vanilla < euroleague_sos/euroleague_lmer.R

psql rockets -f euroleague_sos/normalize_factors.sql
psql rockets -f euroleague_sos/schedule_factors.sql

#psql rockets -f euroleague_sos/connectivity.sql > euroleague_sos/connectivity.txt
psql rockets -f euroleague_sos/current_ranking.sql > euroleague_sos/current_ranking.txt
#psql rockets -f euroleague_sos/division_ranking.sql > euroleague_sos/division_ranking.txt

psql rockets -f euroleague_sos/test_predictions.sql > euroleague_sos/test_predictions.txt

psql rockets -f euroleague_sos/predict_daily.sql > euroleague_sos/predict_daily.txt
psql rockets -f euroleague_sos/predict_spread.sql > euroleague_sos/predict_spread.txt

psql rockets -f euroleague_sos/predict_weekly.sql > euroleague_sos/predict_weekly.txt
