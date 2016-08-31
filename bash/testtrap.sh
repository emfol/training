#!/bin/bash

set -u

declare tmpf

function clean_up {
    if [ -f "$tmpf" ]
    then
        rm -rf "$tmpf" &> /dev/null
        echo "Temp file deleted..."
    fi
}

function clean_up_and_exit {
    clean_up
    exit 1
}

trap 'clean_up_and_exit' SIGINT
trap 'clean_up' EXIT

tmpf=$(mktemp -q)
if [ $? -eq 0 -a -n "$tmpf" ]
then
    echo "Temporary file created: \"$tmpf\""
fi

# let's write something to the file...
echo 'Oops!' > "$tmpf"

# give the user a chance to kill the process...
sleep 10

# print file contents..
cat "$tmpf"

exit 0
