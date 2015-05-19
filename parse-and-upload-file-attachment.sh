#!/bin/sh

# Set the COUCHDBURL environment variable

#export COUCHDBURL=http://localhost:5984/cloudbox
[ "x" == "x${COUCHDBURL}" ] && exit 1

# Expect arg
[ "x" == "x$1" ] && exit 1

# Expect arg to be file
FILE="$1"
[ ! -f "${FILE}" ] && exit 1

echo "${FILE}"

SAFENAME=`echo ${FILE##*/} | tr ' ' '_' | tr -cd '[[:alnum:]]._-' | tr '[' '-' | tr ']' '-' `

ffmetadata() {
    ffmpeg -i "${FILE}" -f ffmetadata -vn -an -loglevel quiet -
    LOOKSLIKE="
title=The Mask 2
director=Name
series=The Mask
season=
episode=
genre=Comedy
disc=1/1
"
}

getmeta() {
    DIRECTOR="`ffmetadata|grep '^director='     |sed 's/^director=//'    | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
       TITLE="`ffmetadata|grep '^title='        |sed 's/^title=//'       | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
      SERIES="`ffmetadata|grep '^series='       |sed 's/^series=//'      | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
      SEASON="`ffmetadata|grep '^season='       |sed 's/^season=//'      | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
       GENRE="`ffmetadata|grep '^genre='        |sed 's/^genre=//'       | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
     EPISODE="`ffmetadata|grep '^episode='      |sed 's/^episode=//'     | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
        DISC="`ffmetadata|grep '^disc='         |sed 's/^disc=//'        | sed 's/\\\=/_/g'| sed 's/\\\#/_/g'| tr '"' "'"`"
    [ "x" != "x${DIRECTOR}" ] &&         DIRECTOR="\"director\":    \"${DIRECTOR}\","
    [ "x" != "x${TITLE}" ] &&               TITLE="\"title\":       \"${TITLE}\","
    [ "x" != "x${SERIES}" ] &&             SERIES="\"series\":      \"${SERIES}\","
    [ "x" != "x${SEASON}" ] &&             SEASON="\"season\":      \"${SEASON}\","
    [ "x" != "x${GENRE}" ] &&               GENRE="\"genre\":       \"${GENRE}\","
    [ "x" != "x${EPISODE}" ] &&           EPISODE="\"episode\":     \"${EPISODE}\","
    [ "x" != "x${DISC}" ] &&                 DISC="\"disc\":        \"${DISC}\","
    [ "x" == "x${TITLE}" ] &&               TITLE="\"title\":       \"${SAFENAME}\","
}

# Determine file type
MIME=`file --brief --mime-type "${FILE}"`

# Hash with sha512 to hex
#HEXHASH=`shasum -a 512 "${FILE}" | awk '{print $1}'`
#HEXHASH=`openssl dgst -sha512 -binary "${FILE}" | openssl enc -base64 | openssl enc -d -base64 | od -An -vtx1 | tr -d '\n' | tr -d ' '`
HEXHASH=`openssl dgst -sha512 -hex "${FILE}" | awk '{print $NF}'`

# Hash with sha512 to base64 (smaller for JSON)
BHASH=`openssl dgst -sha512 -binary "${FILE}" | openssl enc -base64 | tr -d '\n'`

# Set the upload type
if echo "${MIME}" | grep "video/x-matroska" >/dev/null ; then
    # mp3
    # We can parse ID3
    TYPE=mkv
    getmeta
elif echo "${MIME}" | grep "video/mp4" >/dev/null ; then
    # m4a
    # We can parse, but may have to convert
    TYPE=mp4
    getmeta
elif echo "${MIME}" | grep "video/x-msvideo" >/dev/null ; then
    # wav
    # We can parse, but may have to convert
    TYPE=avi
    getmeta
else
    echo "Not sure what it is, improper metadata"
    exit 1
fi

# Set the JSON doc data
JSON="{\"sha512\":\"${BHASH}\",${ARTIST}${TITLE}${ALBUM}${ALBUM_ARTIST}${GENRE}${TRACK}${DISC}\"type\":\"${TYPE}\",\"content_type\":\"${MIME}\"}"

# put first to get doc.rev
REV=`curl   -k -s -H 'Content-type: application/json' -X PUT -d "${JSON}" ${COUCHDBURL}/${HEXHASH} | tr -d '\n' | egrep -o '"rev":"(.*)"' | awk -F'"' '{print $4}'`

# not upload file data
if [ "x" == "x${REV}" ]; then
    curl -v -k -s -H 'Content-type: application/json' -X PUT -d "${JSON}" ${COUCHDBURL}/${HEXHASH}
    echo "Something went wrong, here's the JSON so you can take a look"
    echo "${JSON}"
else
    curl -k -H "Content-Type: ${MIME}" -X PUT --data-binary @"${FILE}" "${COUCHDBURL}/${HEXHASH}/${SAFENAME}?rev=${REV}"
fi
