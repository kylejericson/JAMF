#!/bin/bash
#Script to grant secure token to another user.
#Add a loop for waiting got the macOS dekstop to load.
#Credits to Travelling Tech Guy
# Version 1.0

function wait_for_gui () {
    # Wait for the dock to determine the current user
    DOCK_STATUS=$(pgrep -x Dock)
    echo "Waiting for Desktop..."

    while [[ "$DOCK_STATUS" == "" ]]; do
        echo "Desktop is not loaded; waiting..."
        sleep 5
        DOCK_STATUS=$(pgrep -x Dock)
    done

	CURRENT_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')
    echo "$CURRENT_USER is logged in and at the desktop; continuing."
}

wait_for_gui

# Travelling Tech Guy - 7/12/18 - V1.0
# Script created as proof of concept for blogpost https://travellingtechguy.eu/script-secure-tokens-mojave

# The idea is to run this prior to enabling FileVault remotely.
# This to ensure we have the correct Secure Tokens in place in case you want to manipulate Secure Tokens with an 'IT Admin' accouont later.
# Mainly to avoid ending up with a FileVault Enabled Mac, with only a tokenised non-admin enduser.

# Script below uses $4 and $5 to pass the "IT Admin" credentials, but I would recommend to have a look at the GitHub link below to add more security.
# Encrypt Admin credentials passed via script in Jamf Pro: https://github.com/jamfit/Encrypted-Script-Parameters/blob/master/EncryptedStrings_Bash.sh

# Flying Dutch Sysadmin - 23/01/19 - V1.2
# Added Checks : - Check if an admin account exists, and if it does if it is admin , if not the script fixes it. 
# Echo statements provided for troubleshooting.

# AS ALWAYS: script provided AS IS. Mainly a proof of concept for the above blogpost. TEST and EVALUATE before using it in production.


# Check if a User is logged in
if pgrep -x "Finder" \
&& pgrep -x "Dock" \
&& [ "$CURRENTUSER" != "_mbsetupuser" ]; then

###### Vars to update###################################

# additional Admin credentials
addAdminUser=$4
#add encryption
addAdminUserPassword=$5
PROMPT_TITLE="Enter your Mac Password"
LOGO="/Library/Resources/logo.png"

###### Vars to update###################################

# Prompt for password
CURRENT_USER=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')


# Validate logo file. If no logo is provided or if the file cannot be found at
# specified path, default to the FileVault icon.
if [[ -z "$LOGO" ]] || [[ ! -f "$LOGO" ]]; then
    /bin/echo "No logo provided, or no logo exists at specified path. Using FileVault icon."
    LOGO="/System/Library/PreferencePanes/Security.prefPane/Contents/Resources/FileVault.icns"
fi

# Convert POSIX path of logo icon to Mac path for AppleScript.
LOGO_POSIX="$(/usr/bin/osascript -e 'tell application "System Events" to return POSIX file "'"$LOGO"'" as text')"

# Get information necessary to display messages in the current user's context.
USER_ID=$(/usr/bin/id -u "$CURRENT_USER")
L_ID=$USER_ID
L_METHOD="asuser"




# Check if the admin provided exists on the system
		if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $addAdminUser admin / 2>&1) =~ "Unable" ]]; then
  		addAdminUserType="LiesItDoesNotExists"
  		else
  		addAdminUserType="AllGood"
		fi
			if [ "$addAdminUserType" = LiesItDoesNotExists ]; then 
			echo "Admin user status: LIES! it did not exist go check the data" && exit 20      
        else
        echo "Admin user status: You where right! the account did exists"
fi
# Check if our admin has a Secure Token

  		if [[ $("/usr/sbin/sysadminctl" -secureTokenStatus "$addAdminUser" 2>&1) =~ "ENABLED" ]]; then
  		adminToken="true"
  		else
    	adminToken="false"
    	fi
  		echo "Admin Token: $adminToken"
# Check if $addAdminUser is actually an administrator

		if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $addAdminUser admin / 2>&1) =~ "yes" ]]; then
  					AdminUserType="ItWasAdmin"
  					else
  					AdminUserType="LiesItWasNotAdmin"
					fi
                    echo "Admin Account Status: $AdminUserType"
#Fixing the admin to make it admin		
		if [ "$AdminUserType" = LiesItWasNotAdmin ]; then
		dscl . -append /groups/admin GroupMembership $addAdminUser 
        echo "Admin Promo status: It wasnt admin but now it is"
		else
        echo "Admin Promo status: No Action Needed "
        fi
# Check if FileVault is Enabled
# I'm not using this variable in the rest of the script. Only added it in case you want to customise the script and enable FileVault at the end if 'fvStatus' is false
		
		if [[ $("/usr/bin/fdesetup" status 2>&1) =~ "FileVault is On." ]]; then
  		fvStatus="true"
  		else
  		fvStatus="false"
  		fi
  		echo "FV Status: $fvStatus"

# Check Secure Tokens Status - Do we have any Token Holder?

		if [[ $("/usr/sbin/diskutil" apfs listcryptousers / 2>&1) =~ "No cryptographic users" ]]; then
	  	tokenStatus="false"
	  	else
	  	tokenStatus="true"	
		fi
		echo "Token Status $tokenStatus"


				# Get the current logged in user
				userName=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

				# Check if end user is admin

					if [[ $("/usr/sbin/dseditgroup" -o checkmember -m $userName admin / 2>&1) =~ "yes" ]]; then
  					userType="Admin"
  					else
  					userType="Not admin"
					fi
					echo "User type: $userType"

				# Check Token status for end user

				  	if [[ $("/usr/sbin/sysadminctl" -secureTokenStatus "$userName" 2>&1) =~ "ENABLED" ]]; then
  					userToken="true"
  					else
			    	userToken="false"
			    	fi
			  		echo "User Token: $userToken"

				# If both end user and additional admin have a secure token

				if [[ $userToken = "true" && $adminToken = "true" ]]; then
				echo "All is good!"
				exit 0
				fi

				

# Get the logged in user's password via a prompt.
								echo "Prompting $CURRENT_USER for their Mac password..."

								echo "Prompting ${userName} for their login password."
								userPass="$(/bin/launchctl "$L_METHOD" "$L_ID" /usr/bin/osascript -e 'display dialog "Please enter the password you use to log in to your Mac:" default answer "" with title "'"${PROMPT_TITLE//\"/\\\"}"'" giving up after 86400 with text buttons {"OK"} default button 1 with hidden answer with icon file "'"${LOGO_POSIX//\"/\\\"}"'"' -e 'return text returned of result')"

								# Check if the password is ok
								passDSCLCheck=`dscl /Local/Default authonly $userName $userPass; echo $?`

								# If password is not valid, loop and ask again
								while [[ "$passDSCLCheck" != "0" ]]; do
								echo "asking again"
								userPassAgain="$(/usr/bin/osascript -e 'Tell application "System Events" to display dialog "Wrong Password!" default answer "" with title "Login Password" with text buttons {"Ok"} default button 1 with hidden answer' -e 'text returned of result')"
								userPass=$userPassAgain
								passDSCLCheck=`dscl /Local/Default authonly $userName $userPassAgain; echo $?`
								done 

								if [ "$passDSCLCheck" -eq 0 ]; then
								    echo "Password OK for $userName"
								fi

				# If additional admin has a token but end user does not

				if [[ $adminToken = "true" && $userToken = "false" ]]; then
				sysadminctl -adminUser $addAdminUser -adminPassword $addAdminUserPassword -secureTokenOn $userName -password $userPass

				echo "Token granted to end user!"

				diskutil apfs listcryptousers /
				fi

				# If no Token Holder exists, just grant both admin and end user a token
				if [[ $tokenStatus = "false" && $userToken="false" ]]; then
				sysadminctl -adminUser $addAdminUser -adminPassword $addAdminUserPassword -secureTokenOn $userName -password $userPass

				echo "Token granted to both additional admin and end user!"

				diskutil apfs listcryptousers /
				fi

				# If end user is an admin Token holder while our additional admin does not have one

				if [[ $userType = "Admin" && $userToken = "true" && $adminToken = "false" ]]; then
				sysadminctl -adminUser $userName -adminPassword $userPass -secureTokenOn $addAdminUser -password $addAdminUserPassword

				echo "End user admin token holder granted token to additional admin!"

				diskutil apfs listcryptousers /
				fi

				# If end user is a non-admin token holder and our additional admin does not have a Token yet

				if [[ $userType = "Not admin" && $userToken = "true" && $adminToken = "false" ]]; then
				echo "Houston we have a problem!"
				#Here you could update an extension attribute (API CALL) to group problematic Macs in a smart group.
				#The only workaround to fix this is to promote the end user to admin, leverage it to manipulate the tokens and demote it again.
				#I tried it, it works and it does not harm the tokens.
				#dscl . -append /groups/admin GroupMembership $userName
                /usr/sbin/dseditgroup -o edit -a $userName -t user admin
				echo "End user promoted to admin!"

				sysadminctl -adminUser $userName -adminPassword $userPass -secureTokenOn $addAdminUser -password $addAdminUserPassword
				echo "End user admin token holder granted token to additional admin!"

				diskutil apfs listcryptousers /

				#dscl . -delete /groups/admin GroupMembership $userName
                /usr/sbin/dseditgroup -o edit -d $userName -t user admin
				echo "End user demoted back to standard!"	
				#exit 1
				fi

# Here you could call a custom trigger to run a jamf Policy enabling FileVault
#	or update smartgroup via 'jamf recon' to push a Configuration Profile to enable Filevault via an extension attribute (API CALL.

# In case you are running this script on Macs where FileVault was already enabled, your admin account will still get a Secure Token,
#	... unless your non-admin end user was the only token holder.
# However, creating Secure Tokens post FileVault enablement does not make the account show up ad preBoot automatically.
# 	... you will need to run the following command to do so.
# diskutil apfs updatepreBoot /

# This compared to the fact that enabling FileVault does add all existing Secure Token Holders automatically to the preBoot Filevault enabled users

else
	echo "No user logged in"
	exit 1
fi