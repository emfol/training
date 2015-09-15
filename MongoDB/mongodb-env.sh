#!/bin/bash

if [ -z "$MONGODB_HOME" ]
then
    export MONGODB_HOME="/usr/local/pkg/mongodb-3.0.5"
    export PATH=$MONGODB_HOME/bin:$PATH
fi

if [ "$SCRIPT_ID" = "MONGODB_MONGOD_CTRL" ] && [ -n "$SCRIPT_DIR" ]
then
    export MONGODB_PORT="27017"
    export MONGODB_DATA="$SCRIPT_DIR/_mongod.dat"
    export MONGODB_LOGF="$SCRIPT_DIR/_mongod.log"
    export MONGODB_PIDF="$SCRIPT_DIR/_mongod.pid"
fi

