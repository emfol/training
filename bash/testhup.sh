#!/bin/bash

declare pidf='pid.txt'
declare -i pid

trap '' SIGHUP

if [ -f "$pidf" ]
then
    pid=$(cat "$pidf")
    if [ $$ -ne $pid ]
    then
        echo 'Daemon already running...'
        exit 1
    fi
    echo 'Daemon executing...'
    sleep 20
    rm -rf "$pidf"
    echo 'Done!'
else
    "$0" < /dev/null >> 'out.txt' 2>&1 &
    echo "$!" > "$pidf"
    echo 'Daemon executed...'
    exit 0
fi


