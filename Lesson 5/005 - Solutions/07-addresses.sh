#!/bin/bash
#
# One way to find "real" users, is to check the valid UID range.
# You will find this in login.defs, for example:
# UID_MIN			 1000
# UID_MAX			60000

# dot-sourcing login.defs to set the variables
UID_MIN=$(grep ^"UID_MIN" /etc/login.defs | awk '{print $2}')
UID_MAX=$(grep ^"UID_MAX" /etc/login.defs | awk '{print $2}')

# Output file for results.
OUTFILE="/tmp/emails.txt"; rm ${OUTFILE} 2>/dev/null

cat /etc/passwd | while read LINE
do
	#echo "DEBUG: Read the following line: ${LINE}."
	echo ${LINE} | cut -d: -f1,3 | tr ":" " " | while read NAME USERID
	do
		if [[ (-z ${USERID}) || (-z ${NAME}) ]] 
		then
		  echo "WARN: Something weird happened."
		  continue
		elif [[ (${USERID} -lt ${UID_MIN}) || (${USERID} -gt ${UID_MAX}) ]] 
		then
		  echo "INFO: Skipping user ${NAME}, uid ${USERID}."
		  continue
		else
		  echo -e "${NAME}\t${NAME}@domain.com" >> ${OUTFILE}
		fi
	done
done

echo "Your results:"
cat ${OUTFILE}

