#!/bin/bash

psql basketball -f bbref_sos/standardized_results.sql

psql basketball -c "drop table bbref._basic_factors;"
psql basketball -c "drop table bbref._parameter_levels;"
psql basketball -c "drop table bbref._factors;"
psql basketball -c "drop table bbref._schedule_factors;"

R --vanilla < bbref_sos/bbref_lmer.R

psql basketball -f bbref_sos/normalize_factors.sql
psql basketball -f bbref_sos/schedule_factors.sql

psql basketball -f bbref_sos/current_ranking.sql > bbref_sos/current_ranking.txt
psql basketball -f bbref_sos/predict_playoffs.sql > bbref_sos/predict_playoffs.txt
