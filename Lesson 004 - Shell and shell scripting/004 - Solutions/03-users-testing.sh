#!/bin/bash
#
# Script to test the sripts for assignment 3.

#########
# Preparations.

# for i in {1..20}
for ((i=1 ; i<=20; i++))
do
  sudo userdel -r "user${i}" 2>/dev/null
  sudo rm -rf "/home/user${i}" 2>/dev/null
done


#########
# First the basic script.

# Without input checking, it should not care about this mistake.
# It should also fail, because you don't indicate an action.
OUTPUT=$(./03-users.sh 2>&1<< EOF
3
EOF
)
[[ ($? -eq 0) ]] && echo "01 Ok." || echo "01 Fail."

# Without input checking, it should not care about this mistake.
# It should also fail, because you don't indicate an action.
OUTPUT=$(./03-users.sh ljlkj 2>&1 << EOF
3
EOF
)
[[ ($? -eq 0) ]] && echo "02 Ok." || echo "02 Fail."

# Without input checking, it should not care about this mistake.
# Should still fail, because no "sudo", so can't make file in homedir.
OUTPUT=$(./03-users.sh create 2>&1 << EOF
3
EOF
)
[[ ($? -eq 0) && (! -z $(echo ${OUTPUT} | grep "denied")) ]] && echo "03 Ok." || echo "03 Fail."

# Proper run, should result in three users and files.
# Quick and dirty test.
OUTPUT=$(sudo ./03-users.sh create 2>&1 << EOF
3
EOF
)
[[ ($? -eq 0) && (-s "/home/user3/welcome.txt") ]] && echo "04 Ok." || echo "04 Fail."

# Without input checking, it should not care about this mistake.
# Should fail without sudo
OUTPUT=$(./03-users.sh remove 2>&1 << EOF
3
EOF
)
[[ ($? -eq 0) && (-d "/home/user3") ]] && echo "05 Ok." || echo "05 Fail."

# Proper run, all three users and homedirs should be gone.
OUTPUT=$(sudo ./03-users.sh remove 2>&1 << EOF
3
EOF
)
[[ ($? -eq 0) && (! -d "/home/user3") ]] && echo "06 Ok." || echo "06 Fail."


#########
# Then the more advanced one.

# Should fail, no correct verb.
OUTPUT=$(./03-users-improved.sh 2>&1)
[[ ($? -eq 1) && (! -z $(echo ${OUTPUT} | grep "sudo")) ]] && echo "07 Ok." || echo "07 Fail."

# Should fail, no sudo
OUTPUT=$(./03-users-improved.sh create 2>&1)
[[ ($? -eq 1) && (! -z $(echo ${OUTPUT} | grep "sudo")) ]] && echo "08 Ok." || echo "08 Fail."

# Should fail, no correct verb.
OUTPUT=$(sudo ./03-users-improved.sh blarf 2>&1)
[[ ($? -eq 1) && (! -z $(echo ${OUTPUT} | grep "activity")) ]] && echo "09 Ok." || echo "09 Fail."

# More complicated test, making ten accounts
OUT="/tmp/output.txt"; sudo rm "${OUT}" 2>/dev/null
sudo ./03-users-improved.sh create &>"${OUT}" << EOF

200
10
EOF
if [[ $? -eq 0 ]] 
then
  FAIL=""
  # Two errors from empty number and 200.
  if [[ $(grep ERROR "${OUT}" | wc -l) -ne 2 ]]; then FAIL="10-1"; fi
  # Ten new users
  if [[ $(grep -v ERROR "${OUT}" | wc -l) -ne 10 ]]; then FAIL="10-2"; fi
  getent passwd user10 &>/dev/null
  if [[ $? -ne 0 ]]; then FAIL="10-3"; fi
  if [[ ! -f /home/user10/welcome.txt ]]; then FAIL="10-4"; fi
  if [[ -z $(grep -i welcome /home/user10/welcome.txt) ]]; then FAIL="10-5"; fi

  [[ ! -z ${FAIL} ]] && echo "${FAIL} Fail." || echo "10 Ok."
else
  echo "10 Fail."
fi

# More complicated test, making twelve accounts over ten existing
OUT="/tmp/output.txt"; sudo rm "${OUT}" 2>/dev/null
sudo ./03-users-improved.sh create &>"${OUT}" << EOF

200
12
EOF
if [[ $? -eq 0 ]] 
then
  FAIL=""
  # Two errors from empty number and 200.
  if [[ $(grep ERROR "${OUT}" | wc -l) -ne 2 ]]; then FAIL="11-1"; fi
  # Ten info messages from pre-existing users
  if [[ $(grep INFO "${OUT}" | wc -l) -ne 10 ]]; then FAIL="11-2"; fi
  # Two new users
  if [[ $(grep -v ERROR "${OUT}" | grep -v INFO | wc -l) -ne 2 ]]; then FAIL="11-3"; fi
  getent passwd user10 &>/dev/null
  if [[ $? -ne 0 ]]; then FAIL="11-4"; fi
  if [[ ! -f /home/user10/welcome.txt ]]; then FAIL="11-5"; fi
  if [[ -z $(grep -i welcome /home/user10/welcome.txt) ]]; then FAIL="11-6"; fi

  [[ ! -z ${FAIL} ]] && echo "${FAIL} Fail." || echo "11 Ok."
else
  echo "11 Fail."
fi

# More complicated test, removing ten accounts.
OUT="/tmp/output.txt"; sudo rm "${OUT}" 2>/dev/null
sudo ./03-users-improved.sh remove &>"${OUT}" << EOF

200
10
EOF
if [[ $? -eq 0 ]] 
then
  FAIL=""
  # Two errors from empty number and 200.
  if [[ $(grep ERROR "${OUT}" | wc -l) -ne 2 ]]; then FAIL="12-1"; fi
  # Ten removed users
  if [[ $(grep -v ERROR "${OUT}" | wc -l) -ne 10 ]]; then FAIL="12-2"; fi
  # User should be gone
  getent passwd user10 &>/dev/null
  if [[ ! $? -gt 0 ]]; then FAIL="12-3"; fi
  # Homedir and file should be gone
  if [[ -f /home/user10/welcome.txt ]]; then FAIL="12-4"; fi

  [[ ! -z ${FAIL} ]] && echo "${FAIL} Fail." || echo "12 Ok."
else
  echo "12 Fail."
fi

# More complicated test, making twelve accounts with ten already gone.
OUT="/tmp/output.txt"; sudo rm "${OUT}" 2>/dev/null
sudo ./03-users-improved.sh remove &>"${OUT}" << EOF

200
12
EOF
if [[ $? -eq 0 ]] 
then
  FAIL=""
  # Two errors from empty number and 200.
  if [[ $(grep ERROR "${OUT}" | wc -l) -ne 2 ]]; then FAIL="13-1"; fi
  # Ten info messages from earlier removed users
  if [[ $(grep INFO "${OUT}" | wc -l) -ne 10 ]]; then FAIL="13-2"; fi
  # Two new users removed
  if [[ $(grep -v ERROR "${OUT}" | grep -v INFO | wc -l) -ne 2 ]]; then FAIL="13-3"; fi
  # Users should be gone
  getent passwd user12 &>/dev/null
  if [[ ! $? -gt 0 ]]; then FAIL="13-4"; fi
  # Files and homedir should be gone
  if [[ -f /home/user12/welcome.txt ]]; then FAIL="13-5"; fi

  [[ ! -z ${FAIL} ]] && echo "${FAIL} Fail." || echo "13 Ok."
else
  echo "13 Fail."
fi



