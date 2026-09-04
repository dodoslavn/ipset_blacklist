#!/bin/bash

#date
#git pull

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

. ../conf/main.conf

mkdir -p ../tmp/

for S in $LIST
  do
  echo '###########'
  echo '###' $S
  ../sources/"$S".sh
  done

echo "##################"
