#!/bin/bash

# Update USB IDs optmisied v0.1

# The URL to download
USBIDS_URL="http://www.linux-usb.org/usb.ids.gz"

# Where to store the ID list
USBIDS_PATH_LIST="/var/lib/usbutils/usb.ids"
USBIDS_PATH_REVISION="/var/lib/usbutils/usb.ids.version"

# Regex
regexETag="ETag: \"([a-z0-9\-]+)\""
regexSize="Content-Length: ([0-9]+)"
regexLastMod="Last-Modified: ([a-zA-Z0-9\/ :,-]+)"
regexHTTPCode="HTTP/[0-9].[0-9] ([0-9]+) ([a-zA-Z0-9\. -]+)"

#Get the HTTP headers for the IDs
USBIDS_HEADERS=`curl -sI "$USBIDS_URL"`

#Get the HTTP response code
[[ $USBIDS_HEADERS =~ $regexHTTPCode ]]
USBIDS_RESPONSE_CODE="${BASH_REMATCH[1]}"
USBIDS_RESPONSE_MSG="${BASH_REMATCH[2]}"

if [ "$USBIDS_RESPONSE_CODE" != 200 ]; then
	echo "Download Error [HTTP $USBIDS_RESPONSE_CODE $USBIDS_RESPONSE_MSG]"
	exit
fi

#Get the date the list was last modified
[[ $USBIDS_HEADERS =~ $regexLastMod ]]
USBIDS_LASTMOD="${BASH_REMATCH[1]}"
USBIDS_LASTMOD=`date --date="$USBIDS_LASTMOD" +%s`

#Get the ID list size
[[ $USBIDS_HEADERS =~ $regexSize ]]
USBIDS_SIZE="${BASH_REMATCH[1]}"

#Get the ID list ETag
[[ $USBIDS_HEADERS =~ $regexETag ]]
USBIDS_ETAG="${BASH_REMATCH[1]}"

