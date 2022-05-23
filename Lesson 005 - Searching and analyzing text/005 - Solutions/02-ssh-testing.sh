#!/bin/bash

OUTPUT=$(./02-ssh.sh)

[[ ($? -eq 0) && (! -z $(echo ${OUTPUT} | grep foobar)) ]] && echo "01 Ok." || echo "01 Fail."

