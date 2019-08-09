#!/bin/bash
#created by Kyle Ericson
#Date Aug 9th 2019
#Version 1.0
#Purpose: Easy to use GUI app to Code Sign PKG files with a Apple Developer ID Installer cert
#Requirements: 
#1.	A Apple Developer ID Installer cert must be installed on the current machine.
#2.	Script to make into .app file     https://gist.github.com/mathiasbynens/674099#file-appify
#3.	Update the Script with your dev ID in the section below

consoleUser=$(stat -f %Su /dev/console)
file=`osascript -e 'tell app (path to frontmost application as Unicode text) to set new_file to POSIX path of (choose file with prompt "Pick a PKG file to CodeSign" of type {"PKG"})'  2> /dev/null`
newname=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter a new name for your signed package.\n\nNote: The signed PKG will be saved your desktop.\n\nImportant: .pkg must be at the end of your filename!" default answer "signed.pkg"' -e 'text returned of result' 2>/dev/null)

####################################################
#Replace this line with your Developer ID Installer:
productsign --sign 'Developer ID Installer: Mordo Inc. (AAA111AA11)' ${file} /Users/$consoleUser/Desktop/${newname}
####################################################


#Result=`/usr/sbin/pkgutil --check-signature "$newname"`

#  "Message"
function msg() {
  osascript <<EOT
    tell app "System Events"
      display dialog "$1" buttons {"OK"} default button 1 with icon file "Macintosh HD:System:Library:CoreServices:CoreTypes.bundle:Contents:Resources:LockedIcon.icns" with title "Code Signing Status"
      return  -- Suppress result
    end tell
EOT
}

msg "Success: $newname is now a signed package. Peace Brother!"

exit 0
