#!/bin/bash

ssh tess@ububu << EOF
touch /tmp/foobar
ls /tmp
EOF

