#!/bin/bash

#psql basketball -f standardized_results.sql

psql basketball -c "drop table ncaa_sr._zim_parameter_levels;"
psql basketball -c "drop table ncaa_sr._zim_basic_factors;"

#psql basketball -c "drop table ncaa_sr._factors;"
#psql basketball -c "drop table ncaa_sr._schedule_factors;"

psql basketball -c "vacuum full verbose analyze ncaa_sr.results;"

R --vanilla -f ncaa_sr_nbinom.R

psql basketball -c "vacuum full verbose analyze ncaa_sr._zim_parameter_levels;"
psql basketball -c "vacuum full verbose analyze ncaa_sr._zim_basic_factors;"

#psql basketball -f normalize_factors.sql

#psql basketball -c "vacuum full verbose analyze ncaa_sr._factors;"

#psql basketball -f schedule_factors.sql

#psql basketball -c "vacuum full verbose analyze ncaa_sr._schedule_factors;"

#psql basketball -f current_ranking.sql > current_ranking.txt

#psql basketball -f predict_daily.sql > predict_daily.txt

#psql basketball -f predict_uk.sql > predict_uk.txt

#psql basketball -f unlucky.sql > unlucky.txt
