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

rm -f $SPAMHAUS_TMPFILE 2>/dev/null

if [ -a "$SPAMHAUS_TMPFILE" ]
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

wget $SMAPHAUS_URL -O $SPAMHAUS_TMPFILE

SPAMHAUS_CURRENT="$( ipset list $SPAMHAUS_IPSETNAME )"

C=0
for SUBNET in $( grep ^[0-9] $SPAMHAUS_TMPFILE | cut -d';' -f1 )
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
rm -f $SPAMHAUS_TMPFILE
