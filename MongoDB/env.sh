#!/bin/bash

if [ -z "$MONGODB_PATH" ]
then
    export MONGODB_PATH="/usr/local/pkg/mongodb-3.0.5"
    export PATH=$MONGODB_PATH/bin:$PATH
    echo "MongoDB Env Enabled..."
fi

