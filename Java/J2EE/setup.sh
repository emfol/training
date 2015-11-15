#!/bin/sh

JETTY_NAME="jetty-distribution-8.1.17.v20150415"
JETTY_ARCHIVE="$JETTY_NAME.tar.gz"
JETTY_BASEURL="http://download.eclipse.org/jetty/8.1.17.v20150415/dist"
JETTY_DEST="container"
TMPDIR=".cache"
DWNDIR="$TMPDIR/downloads"

_abort() {
    echo "Aborting..."
    exit 1;
}

# create downloads dir...
if [ ! -d "$DWNDIR" ]
then
    mkdir -p -- "$DWNDIR"
fi

# download jetty
if [ ! -f "$DWNDIR/$JETTY_ARCHIVE" ]
then
    echo "Downloading Jetty..."
    curl -L -o "$DWNDIR/$JETTY_ARCHIVE" -- "$JETTY_BASEURL/$JETTY_ARCHIVE"
    if [ $? -ne 0 ]
    then
        rm -f "$DWNDIR/$JETTY_ARCHIVE"
        _abort
    fi
fi

# unpack jetty archive
if [ ! -e "$JETTY_DEST" ] && [ -f "$DWNDIR/$JETTY_ARCHIVE" ]
then
    echo "Extracting..."
    tar xzf "$DWNDIR/$JETTY_ARCHIVE"
    if [ $? -ne 0 ]
    then
        _abort
    fi
fi

# rename dist folder
if [ ! -e "$JETTY_DEST" ] && [ -e "$JETTY_NAME" ]
then
    echo "Moving files..."
    mv -- "$JETTY_NAME" "$JETTY_DEST"
fi

echo "Done!"
