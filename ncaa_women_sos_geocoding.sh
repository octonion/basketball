#!/bin/bash

psql basketball -f ncaa_women_sos/standardized_results.sql

psql basketball -c "drop table ncaa_women._basic_factors_geocoding;"
psql basketball -c "drop table ncaa_women._parameter_levels_geocoding;"

psql basketball -c "vacuum analyze ncaa_women.results;"

R --vanilla < ncaa_women_sos/ncaa_lmer_geocoding.R

psql basketball -f ncaa_women_sos/normalize_factors_geocoding.sql
psql basketball -f ncaa_women_sos/schedule_factors_geocoding.sql

psql basketball -f ncaa_women_sos/current_ranking.sql > ncaa_women_sos/current_ranking_geocoding.txt
psql basketball -f ncaa_women_sos/division_ranking.sql > ncaa_women_sos/division_ranking_geocoding.txt
