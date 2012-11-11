#!/bin/bash

#wget -e robots=off --recursive --level=2 --continue --follow-tag=a,href http://basketballvalue.com/downloads.php
#wget --mirror --domains=basketballvalue.com --follow-tags=a,href http://basketballvalue.com/downloads.php

wget http://www.basketballvalue.com/publicdata/AllData20120510040.zip
wget http://www.basketballvalue.com/publicdata/AllData20102011reg20110416.zip
wget http://www.basketballvalue.com/publicdata/AllData20092010reg20100418.zip
wget http://www.basketballvalue.com/publicdata/AllData20082009reg20090420.zip
wget http://www.basketballvalue.com/publicdata/AllData20072008reg20081211.zip
#wget http://www.basketballvalue.com/publicdata/AllData20070420.zip
#wget http://www.basketballvalue.com/publicdata/AllData20060928.zip

for file in *.zip
do
 unzip $file
done
