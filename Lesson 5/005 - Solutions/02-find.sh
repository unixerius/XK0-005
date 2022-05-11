#!/bin/bash

# Find all files with "passwd" in their name.

find / -name "*passwd*" -type f 2>/dev/null

# Find all files named "passwd".

find / -name "passwd" -type f 2>/dev/null

# Find all world-writable files.
# This means that the "other" permission includes write.

find / -perm -o+w -type f 2>/dev/null

