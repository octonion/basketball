#!/bin/bash

psql basketball -f sos_reg/standardized_results.sql

psql basketball -c "drop table ncaa_sr.beta_basic_factors;"
psql basketball -c "drop table ncaa_sr.beta_parameter_levels;"
psql basketball -c "drop table ncaa_sr.beta_factors;"
psql basketball -c "drop table ncaa_sr.beta_schedule_factors;"

psql basketball -c "vacuum full verbose analyze ncaa_sr.beta_results;"

R --vanilla -f sos_reg/lmer.R

psql basketball -c "vacuum full verbose analyze ncaa_sr.beta_basic_factors;"
psql basketball -c "vacuum full verbose analyze ncaa_sr.beta_parameter_levels;"

psql basketball -f sos_reg/normalize_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr.beta_factors;"

psql basketball -f sos_reg/schedule_factors.sql

psql basketball -c "vacuum full verbose analyze ncaa_sr.beta_schedule_factors;"

psql basketball -f sos_reg/current_ranking.sql > sos_reg/current_ranking.txt

psql basketball -f sos_reg/predict_postseason.sql > sos_reg/predict_postseason.txt
