#!/bin/bash

LOG_FILE="${XDG_CONFIG_HOME:-$HOME}/repos/upyay/test.txt"
PATTERN='[[:space:]]?[0-9]+[[:space:]]+([a-zA-Z])'

# grep -E "^([a-zA-Z0-9\/-])+[\s]+[0-9a-z.:-]+[\s]+[->]{2}[\s][0-9a-z.:-]+$" ./test.txt
grep -E '[[:space:]]?[0-9]+[[:space:]]+.*[[:space:]]+->([[:space:]]+|$)' "$LOG_FILE"

# grep -E '.*[[:space:]]+->([[:space:]]+|$)' "$LOG_FILE"