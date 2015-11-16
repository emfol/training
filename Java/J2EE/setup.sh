#!/bin/sh

JETTY_VERSION="8.1.17.v20150415"
JETTY_NAME="jetty-distribution-$JETTY_VERSION"
JETTY_ARCHIVE="$JETTY_NAME.tar.gz"
JETTY_BASEURL="http://download.eclipse.org/jetty/$JETTY_VERSION/dist"
JETTY_DEST="target"

TMPDIR=".cache"
DWNDIR="$TMPDIR/downloads"
RUNDIR=$(pwd)

_script_abort() {
    echo "Aborting..."
    exit 1
}

_script_download_jetty() {
    local RESULT
    if command -v wget > /dev/null 2>&1
    then
        cd "$DWNDIR"
        wget "$JETTY_BASEURL/$JETTY_ARCHIVE"
        RESULT=$?
        cd "$RUNDIR"
    elif command -v curl > /dev/null 2>&1
    then
        curl -L -o "$DWNDIR/$JETTY_ARCHIVE" "$JETTY_BASEURL/$JETTY_ARCHIVE"
        RESULT=$?
    else
        echo "Download tool not found... Please install wget or curl and try again."
        RESULT=1
    fi
    return $RESULT
}

# create downloads dir...
if [ ! -e "$DWNDIR" ]
then
    mkdir -p "$DWNDIR"
fi

# download jetty
if [ ! -f "$DWNDIR/$JETTY_ARCHIVE" ]
then
    echo "Trying to download Jetty..."
    _script_download_jetty
    if [ $? -ne 0 ]
    then
        rm -f "$DWNDIR/$JETTY_ARCHIVE" > /dev/null 2>&1
        _script_abort
    fi
fi

# unpack jetty archive
if [ ! -e "$JETTY_DEST" ] && [ -f "$DWNDIR/$JETTY_ARCHIVE" ]
then
    echo "Extracting..."
    tar xzf "$DWNDIR/$JETTY_ARCHIVE"
    if [ $? -ne 0 ]
    then
        _script_abort
    fi
fi

# rename dist folder
if [ ! -e "$JETTY_DEST" ] && [ -e "$JETTY_NAME" ]
then
    echo "Moving files..."
    mv "$JETTY_NAME" "$JETTY_DEST"
fi

echo "Done!"

