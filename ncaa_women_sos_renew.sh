#!/bin/bash

psql basketball -f ncaa_women_sos/normalize_factors.sql
psql basketball -f ncaa_women_sos/schedule_factors.sql

psql basketball -f ncaa_women_sos/connectivity.sql > ncaa_women_sos/connectivity.txt
psql basketball -f ncaa_women_sos/current_ranking.sql > ncaa_women_sos/current_ranking.txt
psql basketball -f ncaa_women_sos/division_ranking.sql > ncaa_women_sos/division_ranking.txt

psql basketball -f ncaa_women_sos/test_predictions.sql > ncaa_women_sos/test_predictions.txt

psql basketball -f ncaa_women_sos/predict_daily.sql > ncaa_women_sos/predict_daily.txt
