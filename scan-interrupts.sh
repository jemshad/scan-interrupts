#!/bin/bash

# Written for 40 core cpu
# TODO: Make it work on any number of cores (lscpu)

INTERVAL="${1:-10}"     #seconds
SAMPLES="${2:-5}"     #how many samples to take
FILE="/proc/interrupts"

awk '
BEGIN { a[300][41] = 0; lines = 0; } 
{
    # skip header lines
    if ($1 !~ /[0-9A-Z]+:$/) { lines++; next }

    # skip when not enough fields to process
    if (NF < 40) { next }
    if (lines == 1) {
        for (i=2; i<=41; i++) {
            a[$1][i] = $i
        }
    } else {
        printf "%4s", $1
        for (i=2; i<=41; i++) {
            d = $i - a[$1][i]
            printf "%4d ",$i-a[$1][i]
            a[$1][i] = $i
        }
        printf "%s %s\n", $42, $43
    }
}' < <(for loop in $(seq $SAMPLES); do cat $FILE; sleep $INTERVAL; done)
