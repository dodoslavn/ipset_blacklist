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

if [ -z $( ipset list -n | grep ^"$DE_IPSETNAME"$ ) ]
  then
  echo "WARNING: IPset $DE_IPSETNAME doesnt exist, creating new"
  ipset create $DE_IPSETNAME hash:ip
  fi

if [ -z "$( iptables-save | grep $DE_IPSETNAME )" ]
  then
  echo "WARNING: IPset $DE_IPSETNAME is not applied in iptables, applying"
  iptables -I INPUT 1 -m set --match-set $DE_IPSETNAME src -j $DE_RULE
  fi

SIZE=$( ipset list $DE_IPSETNAME | wc -l )
if [ "$SIZE" -gt 65000 ]
    then
    echo "WARNING: Size of this IPset is too big ($SIZE), flushing it"
    ipset flush $DE_IPSETNAME
    fi

wget $DE_URL -O $TMP_FILE


DE_CURRENT="$( ipset list $DE_IPSETNAME )"

C=0
C_OLD=0
for SUBNET in $( grep '\.' $TMP_FILE )
  do
  if [ -z "$( echo "$DE_CURRENT" | grep "$SUBNET" )" ]
    then
    if [ "$C" -gt 0 ] && [ "$C_OLD" -ne "$C" ]
      then
      echo
      fi
    C_OLD=$C
    echo "INFO: Adding "$SUBNET
    ipset add $DE_IPSETNAME $SUBNET
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
echo "INFO: $C subnets were already added."
rm -f $TMP_FILE
