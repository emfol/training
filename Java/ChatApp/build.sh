#!/bin/bash

ENCODING="UTF-8"
DIR_DEST="target/classes"
DIR_SRC="src/main/java"

if [ ! -d $DIR_DEST ]
then
	mkdir -p "$DIR_DEST"
fi

javac -d "$DIR_DEST" -encoding "$ENCODING" -sourcepath "$DIR_SRC" src/main/java/com/example/chatapp/*.java
