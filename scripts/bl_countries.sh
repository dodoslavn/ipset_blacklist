#!/bin/bash

cd "$(dirname "$0")"

if [ "$( whoamo )" != "root" ]
  then
  echo "ERROR: You need to be root!"
  exit 2
  fi

if ! [ -a "../conf/main.conf" ]
  then
  echo "ERROR: Conf file not found!"
  exit 1
  fi

. ../conf/main.conf

rm -f $COUNTRY_FILE".txt" 2>/dev/null

if [ -a "$COUNTRY_FILE.txt" ]
  then
  echo "ERROR: Cannot refresh data!"
  exit 2
  fi

wget $COUNTRY_URL -O $COUNTRY_FILE".txt"

COUNTRY_COMPLETELIST="$( grep "aggregated.zone" $COUNTRY_FILE".txt" | cut -d'"' -f2 | cut -d'-' -f1 )"

echo "$COUNTRY_COMPLETELIST"

exit

COUNTRY_URL="http://www.ipdeny.com/ipblocks/data/aggregated/ru-aggregated.zone"
COUNTRY_FILE="/tmp/bl_country"
COUNTRY_RULE="DROP"
COUNTRY_IPSETNAME="blacklist_country_"
COUNTRY_BLOCK="ru cn"
