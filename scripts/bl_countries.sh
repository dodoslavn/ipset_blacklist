#!/bin/bash

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

rm -f $COUNTRY_FILE".txt" 2>/dev/null

if [ -a "$COUNTRY_FILE.txt" ]
  then
  echo "ERROR: Cannot refresh data!"
  exit 2
  fi

wget $COUNTRY_URL -O $COUNTRY_FILE".txt"

COUNTRY_COMPLETELIST="$( grep "aggregated.zone" $COUNTRY_FILE".txt" | cut -d'"' -f2 | cut -d'-' -f1 )"

echo "INFO: Found list of "$( echo "$COUNTRY_COMPLETELIST" | wc -l )" countries"


for COUNTRY_NAME in $COUNTRY_BLOCK
  do
  if [ -z "$( echo "$COUNTRY_COMPLETELIST" | grep ^"$COUNTRY_NAME"$ )" ]
    then
    echo "ERROR: Country $COUNTRY_NAME was not found in the list!"
    exit 2
    fi
  wget "http://www.ipdeny.com/ipblocks/data/aggregated/"$COUNTRY_NAME"-aggregated.zone" -O $COUNTRY_FILE"_"$COUNTRY_NAME".txt"
  if [ -z $( ipset list -n | grep ^"$COUNTRY_IPSETNAME""$COUNTRY_NAME"$ ) ]
    then
    echo "WARNING: IPset "$COUNTRY_IPSETNAME""$COUNTRY_NAME" doesnt exist, creating new"
    ipset create "$COUNTRY_IPSETNAME""$COUNTRY_NAME" hash:net
    fi

  if [ -z "$( iptables-save | grep "$COUNTRY_IPSETNAME""$COUNTRY_NAME" )" ]
    then
    echo "WARNING: IPset "$COUNTRY_IPSETNAME""$COUNTRY_NAME" is not applied in iptables, applying"
    iptables -I INPUT 1 -m set --match-set "$COUNTRY_IPSETNAME""$COUNTRY_NAME" src -j $COUNTRY_RULE
    fi

  C=0
  C_OLD=0
  COUNTRY_CURRENT="$( ipset list "$COUNTRY_IPSETNAME""$COUNTRY_NAME" | grep ^[0-9] )"
  #IFS=$'\n'
  for SUBNET in $( cat $COUNTRY_FILE"_"$COUNTRY_NAME".txt" )
    do
    if [ -z "$( echo "$COUNTRY_CURRENT" | grep "$SUBNET" )" ]
      then
      if [ "$C" -gt 0 ] && [ "$C_OLD" -ne "$C" ]
        then
        echo
        fi
      C_OLD=$C
      echo "INFO: Adding "$SUBNET" to "$COUNTRY_NAME
      ipset add "$COUNTRY_IPSETNAME""$COUNTRY_NAME" $SUBNET
    else
      #echo "INFO: Subnet $SUBNET is already added."
      C=$(( $C + 1 ))
      echo -n "."
      fi 
    done
  if [ "$C" -gt 0 ]
    then
    echo
    fi
    
  echo "INFO: $C subnets were already added to $COUNTRY_NAME."
  rm -f $COUNTRY_FILE"_"$COUNTRY_NAME".txt"

  done
  
rm -f $COUNTRY_FILE".txt"

