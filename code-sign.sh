#!/bin/bash
#created by Kyle Ericson
#Date Aug 9th 2019
#Version 1.0
#Read me for: code-sign.sh
#This is a easy to use GUI scipt for codesigning .pkg files
#Update the script with your dev ID
#Then use this script to make it into a .app
#https://gist.github.com/mathiasbynens/674099#file-appify


consoleUser=$(stat -f %Su /dev/console)

file=`osascript -e 'tell app (path to frontmost application as Unicode text) to set new_file to POSIX path of (choose file with prompt "Pick a PKG file to CodeSign" of type {"PKG"})'  2> /dev/null`
newname=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter a new name for your signed package.\n\nNote: The signed PKG will be saved your desktop.\n\nImportant: .pkg must be at the end of your filename!" default answer "signed.pkg"' -e 'text returned of result' 2>/dev/null)
echo $file
echo $newname
echo $new_file
#Replace this line with your Developer ID Installer:
productsign --sign 'Developer ID Installer: Mordo Inc. (AAA111AA11)' ${file} /Users/$consoleUser/Desktop/${newname}

Result=`/usr/sbin/pkgutil --check-signature "$newname"`
echo $Result


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
