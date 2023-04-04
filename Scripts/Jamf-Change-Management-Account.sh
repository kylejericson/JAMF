#!/bin/zsh
# Created by OpenAI & Kyle Ericson
# This script will create a new local admin account for use as a new Jamf Pro Management Account
# This will create a new local admin account
# Change the Jamf Management account to this new account
# Update Jamf inventory at the end.
# Add this to a policy with script to run before
# Then add the reset Management account password to random
#######################################################################
# Update with your values below
#

# API user accounts here
# Generate API base64 credentials by using:
# printf "username:password" | iconv -t ISO-8859-1 | base64 -i -
apib64=""

# Create a local admin account on the Mac
new_userdisplayname=""
new_username=""
new_password=""

#######################################################################
# Check if the local admin account already exists
#######################################################################
# Check if the local admin account already exists
dscl . -list /Users |grep $new_username
if [ "$result" != "" ]; then
echo "User: $new_username already exists."
else
echo "User: $new_username doesn't exists."
  # Create the local admin account
  dscl . -create /Users/"$new_username"
  dscl . -create /Users/"$new_username" RealName "$new_userdisplayname"
  dscl . -create /Users/"$new_username" UniqueID 510
  dscl . -create /Users/"$new_username" PrimaryGroupID 80
  dscl . -create /Users/"$new_username" UserShell /bin/zsh
  dscl . -create /Users/"$new_username" NFSHomeDirectory /Users/"$new_username"
  dscl . -passwd /Users/"$new_username" "$new_password"
  dscl . -create /Users/"$new_username" IsHidden 1
  dscl . -append /Groups/admin GroupMembership "$new_username"
  echo "User: $new_username created."
  echo "User: $new_username hidden."
fi

# Current JSS address
jssurl=$( /usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url )

# Hardware UDID of the Mac you're running this on
udid=$( /usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | awk '/IOPlatformUUID/ { split($0, line, "\""); printf("%s\n", line[4]); }' )

jsonresponse=$( /usr/bin/curl -s "${jssurl}api/v1/auth/token" -H "authorization: Basic ${apib64}" -X POST | tr -d "\n" )
token=$( /usr/bin/osascript -l 'JavaScript' -e "JSON.parse(\`$jsonresponse\`).token" )

# Use the read token to find the ID number of the current Mac
computerrecord=$( /usr/bin/curl -s "${jssurl}api/v1/computers-inventory?section=USER_AND_LOCATION&filter=udid%3D%3D%22${udid}%22" -H "authorization: Bearer ${token}" )
id=$( /usr/bin/osascript -l 'JavaScript' -e "JSON.parse(\`$computerrecord\`).results[0].id" )


# echo "Computer ID is: $id" # enable debugging
# echo "API Token is: $token" # enable debugging

#set -x # enable debugging

# Change Jamf management account username and password
echo "Changing Jamf management account username and password..."

# Build XML data for PUT request
xml_data="<computer><general><remote_management><management_username>$new_username</management_username><management_password>$new_password</management_password></remote_management></general></computer>"

# Make PUT request to update management account info
curl -s \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/xml" \
  -X PUT \
  -d "$xml_data" \
  "$jssurl/JSSResource/computers/id/$id"

#set +x # disable debugging

# Invalidate the token
/usr/bin/curl -s -k "${jssurl}api/v1/auth/invalidate-token" -H "authorization: Bearer ${token}" -X POST

/usr/local/jamf/bin/jamf recon

exit 0
