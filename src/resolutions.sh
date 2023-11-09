#!/usr/bin/env bash
# Make sure ARANYM_RESOLUTION is valid and define VNC_RESOLUTION accordingly
#ARANYM_RESOLUTION=$1

echo 'ARANYM_RESOLUTION=' $ARANYM_RESOLUTION
# Extract width, height and nplanes as strings from ARANYM_RESOLUTION
w=$(echo $ARANYM_RESOLUTION | awk -F"x" '{print $1;}')
h=$(echo $ARANYM_RESOLUTION | awk -F"x" '{print $2;}')
n=$(echo $ARANYM_RESOLUTION | awk -F"x" '{print $3;}')

# Just make sure we have 16 pixels aligment for width
iw=$(($w))
let iw=iw/16
let iw=iw*16
# And allocate 8 pixels vertically for host window
ih=$(($h+8))

case "$n" in
 "1" |  "2" |  "4" | "8" | "16" | "24" | "32" )
  ;;
 *)
  n="32" ;;
esac

export ARANYM_RESOLUTION="$iw""x"$h"x"$n"@60"
export VNC_RESOLUTION="$iw""x""$ih""x16"
