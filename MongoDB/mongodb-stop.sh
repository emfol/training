#!/bin/bash

# script id...
SCRIPT_ID="MONGODB_MONGOD_CTRL"
SCRIPT_DIR=$(dirname "$0")

# include mongodb env...
source "$SCRIPT_DIR/mongodb-env.sh"

if [ -f "$MONGODB_PIDF" ]
then
    MONGODB_PID=$(cat -- "$MONGODB_PIDF")
    kill -s SIGTERM "$MONGODB_PID"
    rm -- "$MONGODB_PIDF"
else
    echo "No MongoDB instance running..."
fi

