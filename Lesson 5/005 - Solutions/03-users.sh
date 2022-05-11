#!/bin/bash

# The first positional param will be "create" or "remove".
# Based on that value, we will make or remove user accounts.

ACTION="${1}"

read -p "How many users to ${ACTION}? : " AMOUNT

if [[ (${AMOUNT} -gt 0) && (${AMOUNT} -le 20) ]]
then
  COUNTER=1
  while [[ ${COUNTER} -le ${AMOUNT} ]]
  do
    NAME="user${COUNTER}"
    if [[ ${ACTION} == "create" ]]
    then
      useradd -m "${NAME}"
      cat > "/home/${NAME}/welcome.txt" << EOF
Hi there.
Welcome to your account.
EOF
      let COUNTER+=1
    else
      userdel -r ${NAME} 2>/dev/null
      let COUNTER+=1
    fi 
  done

else
  echo "ERROR: That's too many."
fi


