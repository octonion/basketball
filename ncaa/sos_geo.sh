#!/bin/bash

psql basketball -f sos/standardized_results.sql

psql basketball -c "drop table ncaa._geo_basic_factors;"
psql basketball -c "drop table ncaa._geo_parameter_levels;"

R --vanilla < sos/geo_lmer.R

psql basketball -f sos/geo_normalize_factors.sql
psql basketball -f sos/geo_schedule_factors.sql

#psql basketball -f sos/connectivity.sql > sos/connectivity.txt
psql basketball -f sos/geo_current_ranking.sql > sos/geo_current_ranking.txt
#psql basketball -f sos/division_ranking.sql > sos/division_ranking.txt

#psql basketball -f sos/test_predictions.sql > sos/test_predictions.txt
