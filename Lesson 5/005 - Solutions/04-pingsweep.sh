#!/bin/bash
# 
# This is a very naieve and quick&dirty solution.
# Only takes netmasks of 8, 16 and 24. 
#
# Takes two positional parameters:
# $1 base IP, eg: 192.168.0.0
# $2 netmask in decimal, eg: 24
# This example would scan 192.168.0.1-254.
#
# Or 192.168.0.128.0 and 28 would scan 192.168.0.129-254.
#

BASE=${1}
MASK=${2}

let IPBITS=32-${MASK}
let NETBITS=8-${IPBITS}

if [[ ${MASK} -eq 8 ]]
then
	# Pinging 192.a.b.c
	NEWBASE=$(echo ${BASE} | cut -d"." -f1)

	for a in {0..255}
	do
	  for b in {0..255}
	  do
	    for c in {1..254}
	    do
	      TGT="${NEWBASE}.${a}.${b}.${c}"
	      echo "DEBUG: Trying ${TGT}."
	      ping -c 1 ${TGT} &>/dev/null
	      # Want even more brutal testing?
	      #timeout 1 ping -c 1 ${TGT} &>/dev/null
	    	    
	      [[ $? -eq 0 ]] && echo "${TGT} is up."
	    done
  	  done
	done

elif [[ ${MASK} -eq 16 ]]
then
	# Pinging 192.168.b.c
	NEWBASE=$(echo ${BASE} | cut -d"." -f1-2)

	for b in {0..255}
	do
	  for c in {1..254}
	  do
	    TGT="${NEWBASE}.${b}.${c}"
	    echo "DEBUG: Trying ${TGT}."
	    ping -c 1 ${TGT} &>/dev/null
	    # Want even more brutal testing?
	    #timeout 1 ping -c 1 ${TGT} &>/dev/null
	    	    
	    [[ $? -eq 0 ]] && echo "${TGT} is up."
	  done
	done

elif [[ ${MASK} -eq 24 ]]
then
	# Pinging 192.168.0.c
	for c in {1..254}
	do
		# I didn't know this trick yet either.
		# See https://stackoverflow.com/a/20348214
		# See https://tldp.org/LDP/abs/html/string-manipulation.html
		TGT="${BASE%.*}.${c}"

		echo "DEBUG: Trying ${TGT}."

		ping -c 1 ${TGT} &>/dev/null
		# Want even more brutal testing?
		#timeout 1 ping -c 1 ${TGT} &>/dev/null

		[[ $? -eq 0 ]] && echo "${TGT} is up."
	done
fi

