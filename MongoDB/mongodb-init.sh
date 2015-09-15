#!/bin/bash

# script id...
SCRIPT_ID="MONGODB_MONGOD_CTRL"
SCRIPT_DIR=$(dirname "$0")

# include mongodb env...
source "$SCRIPT_DIR/mongodb-env.sh"

# create data directory...
if [ ! -d $MONGODB_DATA ] && [ ! -f $MONGODB_DATA ]
then
    mkdir -- "$MONGODB_DATA"
fi

# run mongodb daemon...
if [ -d $MONGODB_DATA ] && [ -n "$MONGODB_PORT" ]
then
    echo "Initializing MongoDB @ $MONGODB_PORT..."
    mongod --port "$MONGODB_PORT" --dbpath "$MONGODB_DATA" --logpath "$MONGODB_LOGF" --pidfilepath "$MONGODB_PIDF" &
    echo "Done!"
else
    echo "Cannot initialize MongoDB..."
fi

