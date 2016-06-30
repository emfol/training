#!/bin/bash

if [ 'Darwin' = "$(uname -s)" ]
then
    declare ARGF='-f %z'
else
    declare ARGF='-c %s'
fi

if [ -f "$1" ]
then

    declare FILE="$1"
    declare -i FILE_SIZE=$(stat $ARGF "$FILE")
    declare -i BLK=1
    declare -i N=0
    declare -i I=2

    while [ 0 -eq $(( $FILE_SIZE % $I )) ];
    do
        BLK=$I
        N=$(($N + 1))
        I=$(($I * 2))
    done

    printf 'File       : %s (%d)\n' $FILE $FILE_SIZE
    printf 'Block Size : %d (2^%d)\n' $BLK $N
    printf 'Block Count: %d\n\n' $(($FILE_SIZE / $BLK))

else
    printf "Usage:\n  %s \"/path/to/file\"\n\n" $0
fi

