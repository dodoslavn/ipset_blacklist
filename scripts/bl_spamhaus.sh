#!/bin/bash

cd "$(dirname "$0")"

if ! [ -a "../conf/main.conf" ]
  then
  echo "ERROR: Conf file not found!"
  exit 1
  fi

. ../conf/main.conf

SMAPHAUS_URL="https://www.spamhaus.org/drop/drop.txt"
SPAMHAUS_FILE="/tmp/bl_spamhaus.txt"
