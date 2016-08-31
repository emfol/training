#!/bin/bash

set -u

declare arg
declare -i i=0

for arg in "$@"
do
    let i+=1
    printf '%d. %s\n' $i "$arg"
done
