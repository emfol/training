#!/bin/sh

ENCODING="UTF-8"
CLASSPATH="../../container/lib/servlet-api-3.0.jar"
SOURCE="./src"
TARGET="./classes"
DEPLOY="../../container/webapps/ch-one"

_abort() {
	echo "Aborted..."
    exit 1
}

#build
echo "Building..."
javac -encoding "$ENCODING" -d "$TARGET" -classpath "$CLASSPATH" -sourcepath "$SOURCE" src/*.java
if [ $? -ne 0 ]
then
    _abort
fi

#deploy

if [ -e "$DEPLOY" ]
then
    echo "Removing previous version..."
    rm -Rf "$DEPLOY"
fi

echo "Copying files to container..."
mkdir -p "$DEPLOY/WEB-INF/classes"
cp "etc/web.xml" "$DEPLOY/WEB-INF/"
cp -R ./classes/* "$DEPLOY/WEB-INF/classes"
