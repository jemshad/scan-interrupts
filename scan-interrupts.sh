#!/bin/bash

INTERVAL="${1:-10}"     #seconds
SAMPLES="${2:-5}"     #how many samples to take
FILE="/proc/interrupts"

cpus=$(lscpu | awk '$1 == "CPU(s):" { print $2 }')

awk -vc=$cpus '
BEGIN { a[300][c] = 0; lines = 0; } 
{
    # skip header lines
    if ($1 !~ /[0-9A-Z]+:$/) { lines++; next }

    # skip when not enough fields to process
    if (NF < c) { next }
    if (lines == 1) {
        for (i=2; i<=c+1; i++) {
            a[$1][i] = $i
        }
    } else {
        printf "%4s", $1
        for (i=2; i<=c+1; i++) {
            d = $i - a[$1][i]
            printf "%4d ",$i-a[$1][i]
            a[$1][i] = $i
        }
        printf "%s %s\n", $(c+2), $(c+3)
    }
}' < <(for loop in $(seq $SAMPLES); do cat $FILE; sleep $INTERVAL; done)
