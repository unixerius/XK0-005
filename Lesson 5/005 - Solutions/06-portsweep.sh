#!/bin/bash
# 
# This script builds on 04-pingsweep-improved.sh.
#
# This is a very naieve and quick&dirty solution.
# Only takes netmasks of 8, 16 and 24. 
#
# Creates an output file with the results.
# Thanks to parallelism it now scans a /24 in 36 seconds.
#
# Takes 3+ positional parameters:
# $1 base IP, eg: 192.168.0.0
# $2 netmask in decimal, eg: 24
# $3, $4 and further for ports.
#

# Where does the output go?
OUTFILE="/tmp/portsweep.txt"; rm ${OUTFILE} 2>/dev/null
# How many scans at the same time?
PARALLEL="20"

########
# Validating the input
# Here's a cool article that explains IPv4 address matching with regex.
# https://www.shellhacks.com/regex-find-ip-addresses-file-grep/
# It's not as simple as you'd think!

if [[ $# -lt 3 ]]
then
  echo "ERROR: Wrong amount of arguments; need BASEIP and MASK and at least one PORT."
  exit 1
elif [[ -z $(echo ${2} | grep "^[[:digit:]].*$") ]]
then
  echo "ERROR: Netmask (param 2) is not an integer."  
  exit 1
elif [[ (${2} -lt 1) || (${2} -gt 32) ]]
then
  echo 'ERROR: Netmask (param 2) is not 1-32.'
  exit 1
# This one best matches a real IP address, but boy is it long!
#elif [[ -z $(echo ${1} | grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" ) ]]
elif [[ -z $(echo ${1} | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}") ]]
then
  echo 'ERROR: Base IP (param 1) is not a proper IP address, e.g. 10.0.2.0.'
  exit 1
fi

BASE=${1}
MASK=${2}

let IPBITS=32-${MASK}
let NETBITS=8-${IPBITS}

# Refer to 06-quicktest.sh for more explanation.
# I'm using an array here. We fill it with all passed args.
# Then we start reading from the third element (first port passed).
PORTS=$(echo ${*} | cut -d" " -f3-)
ALLINPUT=(${*})
for ((i=2; i<${#}; i++))
do
  #echo "${ALLINPUT[$i]}"
  if [[ -z $(echo ${ALLINPUT[$i]} | grep "^[[:digit:]].*$") ]]
  then
    echo "WARN: Port ${ALLINPUT[$i]} is not a port number."
    exit 1
  elif [[ ${ALLINPUT[$i]} -gt 65536 ]]
  then
    echo "WARN: Port ${ALLINPUT[$i]} is too high."
    exit 1
  fi
done


########
# Define an extra executable so we can easily background tasks.
# It gets a target IP, an output file and the ports.
# No need to double-check the ports again.
PINGER="/tmp/pinger.sh"; rm ${PINGER} 2>/dev/null

cat > ${PINGER} << EOF
#!/bin/bash
TGT=\${1}
OUTFILE=\${2}
PORTS=\$(echo \${*} | cut -d" " -f3-)

timeout 1 ping -c 1 \${TGT} &>/dev/null 

if [[ \$? -eq 0 ]] 
then
  echo "\${TGT} is up." >> \${OUTFILE}

  for PORT in \$(echo \${PORTS})
  do
    timeout 1 echo "" >/dev/tcp/\${TGT}/\${PORT} 2>/dev/null 
    [[ \$? -eq 0 ]] && echo "\${TGT} has port \${PORT}." >> \${OUTFILE}
  done
fi
EOF

chmod +x ${PINGER}


########
# The actual pingsweep.

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
	      [[ $(ps -C ping | wc -l) -gt ${PARALLEL} ]] && sleep 3
	      TGT="${NEWBASE}.${a}.${b}.${c}"
	      #echo "DEBUG: Trying ${TGT}."
	      ${PINGER} ${TGT} ${OUTFILE} ${PORTS} 2>/dev/null &
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
	    [[ $(ps -C ping | wc -l) -gt ${PARALLEL} ]] && sleep 3
	    TGT="${NEWBASE}.${b}.${c}"
	    #echo "DEBUG: Trying ${TGT}."
	    ${PINGER} ${TGT} ${OUTFILE} ${PORTS} 2>/dev/null &
	  done
	done

elif [[ ${MASK} -eq 24 ]]
then
	# Pinging 192.168.0.c
	for c in {1..254}
	do
	  [[ $(ps -C ping | wc -l) -gt ${PARALLEL} ]] && sleep 3

	  # I didn't know this trick yet either.
	  # See https://stackoverflow.com/a/20348214
	  # See https://tldp.org/LDP/abs/html/string-manipulation.html
  	  TGT="${BASE%.*}.${c}"
	  #echo "DEBUG: Trying ${TGT}."
	  ${PINGER} ${TGT} ${OUTFILE} ${PORTS} 2>/dev/null &
	done
fi

echo "Done. Your results are in ${OUTFILE}."

