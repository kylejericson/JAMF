#!/bin/zsh
# Created by Kyle Ericson
# Quick Add Post-install script

loggedInUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )

# Jamf Pro URL
# This is the your Jamf Pro url without the .jamfcloud.com
url="yourjamfprourlname"
# Jamf Pro Invite URL
# Replace this with the invite ID in Jamf Pro
invite="00000000000000000000000000000000000000"

############

/usr/bin/open -a Safari "https://$url.jamfcloud.com/enroll?invitation=$invite"

for wait_seconds in {1..300}; do
  if [[ -f "/Users/$loggedInUser/Downloads/enrollmentProfile.mobileconfig" ]]; then
    open -b com.apple.systempreferences /System/Library/PreferencePanes/Profiles.prefPane
    sleep 4
    osascript -e 'display dialog "Click install on the MDM Profile.\nThen click install again & type your password.\nThen click ok on this popup message" with icon alias (POSIX file "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Actions.icns")'
    break # Exit loop whenever the file exists to not always wait 5 minutes.
  else
    sleep 1 # Waiting 1 second up to 300 times is a maximum 5 minute wait time.
  fi
done
 
exit 0
