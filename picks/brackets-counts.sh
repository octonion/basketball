#!/bin/bash

awk '{a[$1]++}END{for (i in a) print i,a[i] | "sort"}' OFS="," csv/espn-games.csv > csv/espn-counts.csv
