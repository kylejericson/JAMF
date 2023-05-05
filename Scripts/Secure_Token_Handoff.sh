#!/bin/bash
#Script to grant secure token to another user.
#Add a loop for waiting got the macOS dekstop to load.
#Credits to Travelling Tech Guy
# Version 1.0


# Check if a User is logged in
if pgrep -x "Finder" \
&& pgrep -x "Dock" \
&& [ "$CURRENTUSER" != "_mbsetupuser" ]; then

###### Vars to update###################################
# additional Admin credentials
addAdminUser=$4
addAdminUserPassword=$5
PROMPT_TITLE=$6
LOGO=$7
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
				userName=$(/bin/echo "show State:/Users/ConsoleUser" | /usr/sbin/scutil | /usr/bin/awk '/Name :/&&!/loginwindow/{print $3}')

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
				echo "Promote the enduser to admin to grant token to local itadmin and demote enduser to standard account again"
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


diskutil apfs updatepreBoot /

else
	echo "No user logged in"
	exit 1
fi
