#!/bin/bash

set -u

declare -a pids delays=(15 10 12 4)
declare -i i j k

function is_alive {
    local -i pid=$1
    (( $pid > 0 )) && kill -0 $pid &> /dev/null
}

let i=0
for j in "${delays[@]}"
do
    let i++
    sleep "$j" &
    pids[$i]=$!
    echo "P$i: ${pids[$i]} (${j}s)"
done

echo 'Waiting...'
while true
do
    wait -n
    let i=0
    for j in "${!pids[@]}"
    do
        k=${pids[$j]}
        if (( $k > 0 ))
        then
            if is_alive "$k"
            then
                let i++
            else
                printf 'P%d (%d) just passed away... :(\n' "$j" "$k"
                pids[$j]=0
            fi
        fi
    done
    if (( $i == 0 ))
    then
        echo 'No more child processess...'
        break
    fi
done

echo 'Done!'
