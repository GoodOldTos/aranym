#!/usr/bin/env bash
RESOLUTION=$1
fvdi_file=$2

# Identify the resolution line to replace in fvdi.sys
fvdi_entry=$(grep '01r aranym.sys mode' $fvdi_file | grep -v '#')

# Build the line for new resolution
nfvdi_entry="01r aranym.sys mode "$RESOLUTION
echo 'Setting resolution ' $nfvdi_entry 'in fvdi.sys'

# And replace it
sed -i "/$fvdi_entry/c$nfvdi_entry" $fvdi_file
