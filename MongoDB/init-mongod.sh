#!/bin/bash

# basic vars...
MONGO_BIN="/usr/local/pkg/mongodb-3.0.5"
MONGO_PRT="27017"
MONGO_PWD=$(pwd)
MONGO_DAT="$MONGO_PWD/mongod.dat"
MONGO_LOG="$MONGO_PWD/mongod.log"
MONGO_PID="$MONGO_PWD/mongod.pid"

# export new path with mongo bin...
export PATH=$MONGO_BIN/bin:$PATH

if [ ! -d $MONGO_DAT ] && [ ! -f $MONGO_DAT ]
then
    mkdir $MONGO_DAT
fi

if [ -d $MONGO_DAT ]
then
    echo "Initializing MongoDB @ $MONGO_PRT..."
    mongod --port "$MONGO_PRT" --dbpath "$MONGO_DAT" --logpath "$MONGO_LOG" --pidfilepath "$MONGO_PID" &
    echo "Done!"
else
    echo "Cannot initialize MongoDB..."
fi

