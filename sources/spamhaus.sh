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

if [ -z $( ipset list -n | grep ^"$SPAMHAUS_IPSETNAME"$ ) ]
  then
  echo "WARNING: IPset $SPAMHAUS_IPSETNAME doesnt exist, creating new"
  ipset create $SPAMHAUS_IPSETNAME hash:net
  fi

if [ -z "$( iptables-save | grep $SPAMHAUS_IPSETNAME )" ]
  then
  echo "WARNING: IPset $SPAMHAUS_IPSETNAME is not applied in iptables, applying"
  iptables -I INPUT 1 -m set --match-set $SPAMHAUS_IPSETNAME src -j $SPAMHAUS_RULE
  fi

wget $SMAPHAUS_URL -O $TMP_FILE

SPAMHAUS_CURRENT="$( ipset list $SPAMHAUS_IPSETNAME )"

C=0
for SUBNET in $( grep ^[0-9] $TMP_FILE | cut -d';' -f1 )
  do
  if [ -z "$( echo "$SPAMHAUS_CURRENT" | grep "$SUBNET" )" ]
    then
    echo "INFO: Adding "$SUBNET
    ipset add $SPAMHAUS_IPSETNAME $SUBNET
  else
    #echo "INFO: Subnet $SUBNET is already added."
    C=$(( $C + 1 ))
    fi 
  done
  
echo "INFO: $C subnets were already added."
rm -f $TMP_FILE
