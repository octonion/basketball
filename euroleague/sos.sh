#!/bin/bash

psql basketball -f sos/standardized_results.sql

psql basketball -c "drop table euroleague._basic_factors;"
psql basketball -c "drop table euroleague._parameter_levels;"

psql basketball -c "vacuum analyze euroleague.results;"

R --vanilla < sos/euroleague_lmer.R

psql basketball -f sos/normalize_factors.sql
psql basketball -f sos/schedule_factors.sql

psql basketball -f sos/current_ranking.sql > sos/current_ranking.txt

psql basketball -f sos/test_predictions.sql > sos/test_predictions.txt
