#!/bin/bash
# quick script to test input val on unknown amount of params.

echo "Amount of passed params is ${#}."

echo "All passed params are:"
echo "=============="
echo ${*}
echo "=============="

# Arrays? Bash does them, to a degree.
# See: https://opensource.com/article/18/5/you-dont-know-bash-intro-bash-arrays
# Remember, these arrays are 0-indexed.
# The first element is [0].

echo "Using the full array."
ALLINPUT=(${*})
for ELEM in ${ALLINPUT[@]}
do
  echo "${ELEM}"
done

echo ""
echo "Using an extra indexer, starting at 3rd element."

for ((i=2; i<${#}; i++))
do
  echo "${ALLINPUT[$i]}"
done

echo ""
echo "Or, by simply using cut."

ALLINPUT="${*}"
OUTPUT=$(echo ${ALLINPUT} | cut -d" " -f3-)
for i in ${OUTPUT}
do
  echo ${i}
done
