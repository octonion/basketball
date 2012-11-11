#!/bin/bash

psql basketball -f standardized_results.sql

psql basketball -c "drop table bbref._basic_factors;"
psql basketball -c "drop table bbref._parameter_levels;"
psql basketball -c "drop table bbref._factors;"
psql basketball -c "drop table bbref._schedule_factors;"
#psql basketball -c "drop table bbref._game_results;"

R --vanilla < bbref_lmer.R

psql basketball -f normalize_factors.sql
psql basketball -f schedule_factors.sql

psql basketball -f current_ranking.sql > current_ranking.txt
psql basketball -f predict_playoffs.sql > predict_playoffs.txt
