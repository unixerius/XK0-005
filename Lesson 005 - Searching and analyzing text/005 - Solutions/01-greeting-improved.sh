#!/bin/bash
# Now with some defensive coding!

# The name gets passed as positional parameter one, ie $1.
# Let's test if it's set and if it has a decent value.
# For the statement in the elif, see:
# https://www.gnu.org/software/grep/manual/html_node/Character-Classes-and-Bracket-Expressions.html

if [[ -z ${1} ]] 
then
  echo "ERROR: you did not pass a name."
  exit 1
elif [[ -z $(echo ${1} | grep [[:alpha:]]) ]]
then
  echo "ERROR: that's (probably) not a name."
  exit 1
else 
  NAME=${1}
fi

# Let's ask for a greeting.
unset GREET

[[ ! -z ${HOME} ]] && GREETFILE="${HOME}/.greet.cfg" || GREETFILE="./.greet.cfg"

# if $2 was -r, we reset the stored greeting.
[[ ${2} == "-r" ]] && rm ${GREETFILE} 2>/dev/null

if [[ (-f "${GREETFILE}") && (-s "${GREETFILE}") ]]
then
  GREET=$(head -1 "${GREETFILE}")
  #echo "DEBUG: Read greeting from config file."
else
  while [[ (-z ${GREET}) ]]
  do
    #echo "DEBUG: No config file found, reading new greeting."
    touch "${GREETFILE}"
    read -p "How would you like to be greeted? : " GREET
    echo ${GREET} > "${GREETFILE}"
  done
fi

echo "${GREET} ${NAME}."

