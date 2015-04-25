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

#Get the current revision if there is one
if [ -f "$USBIDS_PATH_REVISION" ]; then
	USBIDS_VERSION=`cat "$USBIDS_PATH_REVISION"`
fi

# Check if the version we requested is different from the current one
if [ "$USBIDS_VERSION" = "$USBIDS_ETAG" ]; then
	echo "We already have the latest version"
	exit
fi

# Backup the list
cp -a "$USBIDS_PATH_LIST" "$USBIDS_PATH_LIST"~

# Download the new list
curl -sL "$USBIDS_URL" | pv -s "$USBIDS_SIZE" -cN "Download" | zcat | pv -cN "Extract" > "$USBIDS_PATH_LIST"

# Write the new version to the version file
echo "$USBIDS_ETAG" > "$USBIDS_PATH_REVISION"