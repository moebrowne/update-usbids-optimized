# Update USB IDs

This tool is a more intelligent version of the default `update-usbids` command.
It uses the ETag header sent by the USB ID list server http://www.linux-usb.org to check if we already have the most up to date list.

## Usage

    ./update-usbids.sh

## Parameters

The following optional parameters are available:

    -q	Quiet. Prevent any output.
    -f	Force. Don't check if the list has been updated, download it anyway.
