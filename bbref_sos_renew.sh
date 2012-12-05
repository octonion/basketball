#!/bin/bash

psql basketball -f bbref_sos/normalize_factors.sql
psql basketball -f bbref_sos/schedule_factors.sql

psql basketball -f bbref_sos/current_ranking.sql > bbref_sos/current_ranking.txt
psql basketball -f bbref_sos/predict_playoffs.sql > bbref_sos/predict_playoffs.txt

psql basketball -f bbref_sos/predict_daily.sql > bbref_sos/predict_daily.txt
