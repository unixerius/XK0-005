#!/bin/bash 
#
# Script to test the greeting scripts.
# A number of possible cases are tested for proper handling.

# First the basic script.
OUTPUT=$(./01-greeting.sh << EOF
bla
EOF)
[[ ($? -eq 0) && (${OUTPUT} == "bla .") ]] && echo "01: Ok." || echo "01: Fail."

OUTPUT=$(./01-greeting.sh tess << EOF
bla
EOF)
[[ ($? -eq 0) && (${OUTPUT} == "bla tess.") ]] && echo "02: Ok." || echo "02: Fail."


# Now the more advanced script.

GREETFILE="${HOME}/.greet.cfg"
rm ${GREETFILE} 2>/dev/null

OUTPUT=$(./01-greeting-improved.sh)
[[ ($? -eq 1) && (! -z $(echo ${OUTPUT} | grep ERROR)) ]] && echo "03: Ok." || echo "03: Fail."
rm ${GREETFILE} 2>/dev/null

OUTPUT=$(./01-greeting-improved.sh 543)
[[ ($? -eq 1) && (! -z $(echo ${OUTPUT} | grep ERROR)) ]] && echo "04: Ok." || echo "04: Fail."
rm ${GREETFILE} 2>/dev/null

OUTPUT=$(./01-greeting-improved.sh tess << EOF

bla
EOF)
[[ ($? -eq 0) && (${OUTPUT} == "bla tess.") ]] && echo "05: Ok." || echo "05: Fail."

OUTPUT=$(./01-greeting-improved.sh tess)
[[ ($? -eq 0) && (${OUTPUT} == "bla tess.") ]] && echo "06: Ok." || echo "06: Fail."
rm ${GREETFILE} 2>/dev/null

OUTPUT=$(./01-greeting-improved.sh tess -r << EOF

Hoi
EOF)
[[ ($? -eq 0) && (${OUTPUT} == "Hoi tess.") ]] && echo "07: Ok." || echo "07: Fail."


