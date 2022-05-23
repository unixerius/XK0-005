#!/bin/bash

HOSTLIST="/tmp/hostlist.txt"
OUTDIR="/tmp/suidfind"; rm -rf ${OUTDIR} 2>/dev/null; mkdir ${OUTDIR}

##########
# Prep a quick inputfile.
rm ${HOSTLIST}
[[ ! -f ${HOSTLIST} ]] && cat > ${HOSTLIST} <<EOF
bacon
fakehost
ubuntu
fedora
localhost
EOF

##########
# Unfortunately sudo only reads passwords interactively, or via -S.
# This solution works, but is not secure because the password will
# show up in the listing of "ps -ef" on the target hosts.
#
# Of course, the best way to do this, is with ssh keys and with
# a passwordless sudo rule on the target hosts. 

echo "This script assumes you use the same sudo-password EVERYWHERE."
read -sp "Please enter your password: " PASS

##########
# The actual loop of work

for HOST in $(cat ${HOSTLIST})
do
  getent hosts ${HOST} &>/dev/null
  if [[ $? -gt 0 ]] 
  then
	  echo "Host unknown." > ${OUTDIR}/${HOST}.txt
	  echo "WARN: Skipping unknown ${HOST}."
	  continue
  fi

  ping -c1 ${HOST} &>/dev/null
  if [[ $? -gt 0 ]] 
  then
	  echo "Host down." > ${OUTDIR}/${HOST}.txt
	  echo "WARN: Skipping unreachable ${HOST}."
	  continue
  fi

  # find "-perm -4000" is identical to "-perm -u+s".
  ssh ${HOST} "echo ${PASS} | sudo -S find / -type f -perm -u+s 2>/dev/null" > ${OUTDIR}/${HOST}.txt
done

