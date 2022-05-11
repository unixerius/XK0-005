#!/bin/bash

sudo cp /etc/login.defs /etc/login.defs.orig

grep ^UMASK.*022 /etc/login.defs

# This gives:
# UMASK		022

sudo sed -i 's/^UMASK.*022/UMASK 027/' /etc/login.defs

grep ^UMASK.*02 /etc/login.defs

# This gives:
# UMASK 027

