#!/bin/bash
 
#Written by Kyle Ericson
#Date 12/17/2020
#Version 1.0
 
#####About this Program#######
#this program is designed to let us deploy blackblaze to macs using Datto
#It will pull the DMG with curl and download it to /tmp folder

#Update vars below. 
#If the password is "none" (without the quotes)
#An automatically generated password will be used and the user can request a password reset on our Backblaze website.
##############################################
email=""
passwd="none"
groupID=""
groupToken=""
##############################################


echo "Email= $email" > /var/log/backblaze.log
echo "Password= $paswd" >> /var/log/backblaze.log
echo "Group ID= $groupID" >> /var/log/backblaze.log
echo "Group Token= $groupToken" >> /var/log/backblaze.log
 
 
#check to see if Blackblaze is already installed
if [[ -d "/Applications/Backblaze.app" ]]; then
               echo "Backblaze is already installed, exiting script" >> /var/log/backblaze.log
               exit 0
                              else
               echo "Backblaze not installed, proceeding with install" >> /var/log/backblaze.log
fi
 
#Download the DMG from the Backblaze website
curl https://secure.backblaze.com/mac/install_backblaze.dmg -o /tmp/install_backblaze.dmg >> /var/log/backblaze.log
 
#mount the backblaze .dmg 
hdiutil attach /tmp/install_backblaze.dmg -nobrowse

#run the installer
/Volumes/Backblaze\ Installer/Backblaze\ Installer.app/Contents/MacOS/bzinstall_mate -nogui -createaccount $email $passwd $groupID $groupToken >> /var/log/backblaze.log
 
#pause for 15 seconds to make sure copy operations completed ok
sleep 15
 
#Unmount carbon black DMG disk image
hdiutil detach /Volumes/Backblaze\ Installer || :
 
#Write to log 
echo "Backblaze has been installed" >> /var/log/backblaze.log
echo "Error codes" >> /var/log/backblaze.log
echo "BZERROR:1001 - Successful Installation" >> /var/log/backblaze.log
echo "BZERROR:190 - The System Preferences process is running on the computer. Close System Preferences and retry the installation." >> /var/log/backblaze.log
echo "BZERROR:1000 - This is a general error code. One possible reason is that the Backblaze installer doesn't have root permissions and is failing. Please see the install log file for more details." >> /var/log/backblaze.log
echo "BZERROR:1016 - The intended email address already has a Backblaze account, the group ID is incorrect, or the group token is incorrect." >> /var/log/backblaze.log
exit 0
