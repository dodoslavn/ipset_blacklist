#!/bin/bash

git pull

cd "$(dirname "$0")"

if [ "$( whoami )" != "root" ]
  then
  echo "ERROR: You need to be root!"
  exit 2
  fi

if ! [ -a "../conf/main.conf" ]
  then
  echo "ERROR: Conf file not found!"
  exit 1
  fi

./bl_countries.sh
./bl_de.sh
./bl_spamhaus.sh
