#!/bin/bash

# The name gets passed as positional parameter one, ie $1.
NAME=${1}

# Let's ask for a greeting.

read -p "How would you like to be greeted? : " GREET

echo "${GREET} ${NAME}."

