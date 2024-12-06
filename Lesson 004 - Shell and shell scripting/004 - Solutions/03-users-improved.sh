#!/bin/bash

# Based on the exercise, we need to make sure we're running as root.

if [[ ${EUID} -ne 0 || ${USER} != "root" ]]
then
  echo "This script should be run by the root user."
  exit 1
fi


# The first positional param will be "create" or "remove".
# Based on that value, we will make or remove user accounts.

case ${1} in
create) ACTION="${1}";;
remove) ACTION="${1}";;
* ) echo "ERROR: Wrong activity chosen."; exit 1;;
esac

# Let's ask for the amount.
unset AMOUNT
OKINPUT=0

while [[ (-z ${AMOUNT}) || (${OKINPUT} -ne 1) ]]
do
  read -p "How many users to ${ACTION}? : " AMOUNT

  if [[ -z $(echo ${AMOUNT} | grep "^[[:digit:]]*$") ]]
  then
    echo "ERROR: That's not a number 1-20."
    OKINPUT=0
  elif [[ (${AMOUNT} -lt 1) || (${AMOUNT} -gt 20) ]]
  then
    echo "ERROR: That's not a number 1-20."
    OKINPUT=0
  else 
    OKINPUT=1
  fi
done

# Let's do stuff
COUNTER=1

while [[ ${COUNTER} -le ${AMOUNT} ]]
do
  NAME="user${COUNTER}"

  if [[ ${ACTION} == "create" ]]
  then
    #echo "DEBUG: Trying to ${ACTION} ${NAME}."

    getent passwd "${NAME}" &>/dev/null
    if [[ $? -eq 0 ]] 
    then 
      echo "INFO: Skipping ${NAME}. Already exists."
      let COUNTER+=1
      continue
    fi

    sudo useradd -m "${NAME}"
    if [[ $? -gt 0 ]]
    then
      echo "WARN: ${ACTION} ${NAME} failed."
      let COUNTER+=1
      continue
    fi

    cat > "/home/${NAME}/welcome.txt" << EOF
Hi there.
Welcome to your account.
EOF

    echo "Made ${NAME}."
    let COUNTER+=1

  else
    #echo "DEBUG: Trying to ${ACTION} ${NAME}."

    getent passwd "${NAME}" &>/dev/null
    if [[ $? -ne 0 ]] 
    then 
      echo "INFO: Skipping ${NAME}. Does not exist."
      let COUNTER+=1
      continue
    fi

    sudo userdel -r ${NAME} 2>/dev/null
    if [[ $? -gt 0 ]]
    then
      echo "WARN: ${ACTION} ${NAME} failed."
      let COUNTER+=1
      continue
    fi

    echo "Removed ${NAME}."
    let COUNTER+=1
  fi 
done

