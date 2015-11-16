#!/bin/sh

CONTAINER=$(readlink -f "../../target")
ENCODING="UTF-8"
CLASSPATH="$CONTAINER/lib/servlet-api-3.0.jar"
SOURCE="./src"
TARGET="./target"
DEPLOY="$CONTAINER/webapps/first-servlet"

_script_abort() {
    echo "Aborted..."
    exit 1
}

if [ -e "$TARGET" ]
then
    echo "Cleaning..."
    rm -Rf "$TARGET"
    mkdir -p "$TARGET"
fi

#build
echo "Building..."
javac -encoding "$ENCODING" -d "$TARGET" -classpath "$CLASSPATH" -sourcepath "$SOURCE" src/com/loosingtouch/training/*.java
if [ $? -ne 0 ]
then
    echo "Error during compilation..."
    _script_abort
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
cp -R $TARGET/* "$DEPLOY/WEB-INF/classes"

