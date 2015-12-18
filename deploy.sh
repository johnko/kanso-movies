#!/bin/sh

if [ "x" = "x$1" ]; then
    HOST=localhost
else
    HOST=$1
fi

DBNAME=movies
DBURL=http://${HOST}:5984/${DBNAME}

APPFOLDER=couchapp

kanso install ${APPFOLDER}

kanso push ${APPFOLDER} ${DBURL}
