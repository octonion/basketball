#!/bin/bash

psql basketball -f euroleague_sos/standardized_results.sql

psql basketball -c "drop table euroleague._basic_factors;"
psql basketball -c "drop table euroleague._parameter_levels;"

psql basketball -c "vacuum analyze euroleague.results;"

R --vanilla < euroleague_sos/euroleague_lmer.R

psql basketball -f euroleague_sos/normalize_factors.sql
psql basketball -f euroleague_sos/schedule_factors.sql

#psql basketball -f euroleague_sos/connectivity.sql > euroleague_sos/connectivity.txt
psql basketball -f euroleague_sos/current_ranking.sql > euroleague_sos/current_ranking.txt
#psql basketball -f euroleague_sos/division_ranking.sql > euroleague_sos/division_ranking.txt

psql basketball -f euroleague_sos/test_predictions.sql > euroleague_sos/test_predictions.txt

#psql basketball -f euroleague_sos/predict_daily.sql > euroleague_sos/predict_daily.txt
#psql basketball -f euroleague_sos/predict_spread.sql > euroleague_sos/predict_spread.txt

#psql basketball -f euroleague_sos/predict_weekly.sql > euroleague_sos/predict_weekly.txt
