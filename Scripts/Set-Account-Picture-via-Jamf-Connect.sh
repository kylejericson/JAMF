#!/bin/bash
# Created by Kyle Ericson
# Updated by ChatGPT AI for desktop

WEBURL="https://myazureblobname.blob.core.windows.net/mdm/$EMAIL.png"
USR=$(dscl . -list /Users | grep -v -e '^_' -e 'root' -e 'ericsontechadmin' -e 'daemon' -e 'nobody')

# Make sure the token file exists
TOKEN_BASIC="/private/tmp/token"
if [ ! -f "$TOKEN_BASIC" ]; then
  echo "Error: Token file not found"
  exit 1
fi

# Get the email address from the token
EMAIL=$(awk -F'[,:}]' '{for(i=1;i<=NF;i++){if($i~/\s*"email"\s*/ && $(i+1)!=""){print $(i+1)}}}' /private/tmp/token | tr -d '"' | tr -d ' ')
if [ -z "$EMAIL" ]; then
  echo "Error: Could not retrieve email address from token"
  exit 1
fi

echo "Setting account picture for $USR to $EMAIL"

# Download the images from a url
if ! curl -L "$WEBURL" -o "/tmp/$EMAIL.png"; then
  echo "Error downloading image for user $EMAIL"
  exit 1
fi


# Convert the image to TIFF format
if ! sips -s format tiff "/tmp/$EMAIL.png" --out "/tmp/$EMAIL.tiff"; then
  echo "Error converting image for user $EMAIL"
  exit 1
fi

# Set the user's picture
dscl . create /Users/$USR Picture "/tmp/$EMAIL.tiff"

exit 0
