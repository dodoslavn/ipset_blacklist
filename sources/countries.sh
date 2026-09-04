#!/bin/bash

cd "$(dirname "$0")"
SCRIPT_NAME="$(basename "$0")"
TMP_FILE="../tmp/"$SCRIPT_NAME".txt"

if [ "$( whoami )" != "root" ]
  then
  echo "ERROR: You need to be root!"
  exit 2
  fi

rm -f $TMP_FILE 2>/dev/null

if [ -a "$TMP_FILE" ]
  then
  echo "ERROR: Cannot refresh data!"
  exit 2
  fi

wget $COUNTRY_URL -O $TMP_FILE

COUNTRY_COMPLETELIST="$( grep "aggregated.zone" $TMP_FILE | cut -d'"' -f2 | cut -d'-' -f1 )"

echo "INFO: Found list of "$( echo "$COUNTRY_COMPLETELIST" | wc -l )" countries"

for COUNTRY_NAME in $COUNTRY_BLOCK
  do
  if [ -z "$( echo "$COUNTRY_COMPLETELIST" | grep ^"$COUNTRY_NAME"$ )" ]
    then
    echo "ERROR: Country $COUNTRY_NAME was not found in the list!"
    exit 2
    fi
  wget "http://www.ipdeny.com/ipblocks/data/aggregated/"$COUNTRY_NAME"-aggregated.zone" -O $TMP_FILE.$COUNTRY_NAME
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
  for SUBNET in $( cat $TMP_FILE.$COUNTRY_NAME )
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
  rm -f $TMP_FILE.$COUNTRY_NAME 

  done
  
rm -f $TMP_FILE
