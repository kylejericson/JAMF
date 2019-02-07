#!/bin/bash
#New Mac Setup Checklist
#Created by Kyle Ericson
#Date 1-29-19

#Replace the following with your info

#yourlocaladminaccount
#yourlocaladminpassword
#temppass
#Replace with your share ip and useraccount info
#open 'smb://usr:pass@192.168.1.2/Mac-Setup'


sudo defaults write /Library/Preferences/com.apple.NetworkAuthorization AllowUnknownServers -bool YES


fullname=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the users First & Last name or select Cancel." default answer "John Doe"' -e 'text returned of result' 2>/dev/null)

username=$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Please enter the domain username or select Cancel." default answer "johdoe"' -e 'text returned of result' 2>/dev/null)

#Create user account
/usr/sbin/sysadminctl -addUser "$username" -fullName "$fullname" -password temppass -admin -adminUser yourlocaladminaccount -adminPassword yourlocaladminpassword
#Add to FileVault2
/usr/sbin/sysadminctl -adminUser Administrator -adminPassword TruHelp@1 -secureTokenOn "$username" -password temppass

#filevault2
/usr/bin/expect -f- << EOT
  spawn /usr/bin/fdesetup add -usertoadd "${username}"; 
  expect "Enter the username 'yourlocaladminaccount':*" 
  send -- $(printf '%q' "yourlocaladminaccount") 
  send -- "\r"
  expect "Enter the password 'yourlocaladminpassword':*" 
  send -- $(printf '%q' "yourlocaladminpassword") 
  send -- "\r"
  expect "Enter a password for '/', or the recovery key:*"
  send -- $(printf '%q' "${user_password}")  
  send -- "\r"
  expect eof;
EOT

#rename mac
serial_no=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}' | tail -c 5)
computer_name="${username}-${serial_no}"
/usr/sbin/scutil --set LocalHostName "${computer_name}"
/usr/sbin/scutil --set ComputerName "${computer_name}"
/usr/sbin/scutil --set HostName "${computer_name}"

dscacheutil -flushcache

#Update user location
sudo jamf recon -endUsername $username


  
#Get Computer name
computerName="$computer_name"


#Get Computer Model.
computerModel=$(ioreg -l |grep "product-name" |cut -d ""="" -f 2|sed -e s/[^[:alnum:]]//g | sed s/[0-9]//g)

#Get Serial Number
SERIAL="$(ioreg -l | grep IOPlatformSerialNumber | sed -e 's/.*\"\(.*\)\"/\1/')"

# Lets format it.
printf "New Mac Setup Checklist\t Device Info\t DATE\n" >> /tmp/$computerName.txt
printf "%s\n" "#################################" "Device Info:" "#################################" >> /tmp/$computerName.txt
printf "Computer name =\t $computerName\t $(date)\n" >> /tmp/$computerName.txt
printf "User assigned in Jamf =\t $username\n" >> /tmp/$computerName.txt
printf "Users full name =\t $fullname\n" >> /tmp/$computerName.txt
printf "Computer Serial Number =\t $SERIAL\n" >> /tmp/$computerName.txt
printf "Computer Model =\t $computerModel\n" >> /tmp/$computerName.txt
printf "%s\n" "#################################" "Setup Checklist" "#################################" >> /tmp/$computerName.txt
printf "%s\n" "Open Outlook and Activate and setup email account" "Open OneDrive and let it fully sync files and folders" "Run the OneDrive Setup wizard from Jamf Self Service" "Install Auto Quotes from Self Service" "Run Office Updates" "Run macOS updates" "Print Asset tag" "##################################" "Computer Built by:" >> /tmp/$computerName.txt

#lets make it a CSV
tr '\t' ',' </tmp/$computerName.txt >~/Desktop/$computerName.csv

loggedInUser=`/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }'`
echo $loggedInUser
sudo chown -v $loggedInUser:staff "/Users/$loggedInUser/Desktop/$computerName.csv"

#Replace with your share
open 'smb://usr:pass@192.168.1.2/Mac-Setup'

sleep 15
 
echo "/Users/$loggedInUser/Desktop/$computerName.csv"

cp "/Users/$loggedInUser/Desktop/$computerName.csv" /Volumes/Mac-Setup/



sleep 2
sudo defaults write /Library/Preferences/com.apple.NetworkAuthorization AllowUnknownServers -bool NO

umount /Volumes/Mac-Setup

Log out user
echo "Logout time"
pkill loginwindow
   
exit 0
