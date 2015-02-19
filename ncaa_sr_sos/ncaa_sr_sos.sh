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

psql basketball -f current_daily.sql > current_daily.txt

psql basketball -f predict_uk.sql > predict_uk.txt

psql basketball -f unlucky.sql > unlucky.txt
