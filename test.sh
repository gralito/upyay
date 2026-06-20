#!/bin/bash

LOG_FILE="${XDG_CONFIG_HOME:-$HOME}/repos/upyay/test.txt"
PATTERN='[[:space:]]?[0-9]+[[:space:]]+([a-zA-Z])'

# grep -E "^([a-zA-Z0-9\/-])+[\s]+[0-9a-z.:-]+[\s]+[->]{2}[\s][0-9a-z.:-]+$" ./test.txt
mapfile -t upd_pkgs < <(grep -E '[[:space:]]?[0-9]+[[:space:]]+.*[[:space:]]+->([[:space:]]+|$)' "$LOG_FILE" | 
                           awk '{
                               # Split package name in repo and package
                               split($2, package, "/")
                               # Extract old version, new version
                               # Remove leading/trailing whitespace from versions
                               gsub(/^[ \t]+/, "", $3)
                               gsub(/[ \t]+$/, "", $5)
                               # Format output
                               print "=> " package[2]
                               print "\t repo : " package[1]
                               print "\t version : " $3 " → " $5
                           }')
# grep -E '.*[[:space:]]+->([[:space:]]+|$)' "$LOG_FILE"