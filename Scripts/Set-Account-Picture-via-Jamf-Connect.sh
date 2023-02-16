#!/bin/bash
# Created by Kyle Ericson
# Make sure to check your token for the right value for $EMAIL I set mine to upn line 9
# Update Line 14 with your Azure Storage blob

USR=$(dscl . list /Users | grep -v '^_' | grep -v 'root' | grep -v 'nobody' | grep -v 'daemon' | grep -v 'ericsontechadmin' | grep -v '/')
#AL=$(dscl . read /Users/$USR RecordName | grep -v "com.apple.idms.appleid.prd*")
TOKEN_BASIC="/private/tmp/token"
EMAIL=$(echo "$(cat $TOKEN_BASIC)" | sed -e 's/\"//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | grep upn | cut -d ":" -f2)
EMAIL=$(echo "$EMAIL" | sed 's/}//')
echo "Setting account picture for user:$EMAIL"

# Download the images
curl -L "https://myazureblobname.blob.core.windows.net/mdm/$EMAIL.png" -o /tmp/$EMAIL.png

#Convert the Image to tiff
sips -s format tiff /tmp/$EMAIL.png --out /tmp/$EMAIL.tiff

#Remove Old Images
dscl . delete /Users/$USR JPEGPhoto

#Set Images
dscl . create /Users/$USR Picture "/tmp/$EMAIL.tiff"

exit 0
