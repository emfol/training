#!/bin/sh

LS=`ls .`
select DIR in $LS
do
    echo "Selected: $DIR"
    break
done;

