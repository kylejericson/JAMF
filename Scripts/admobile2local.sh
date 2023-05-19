#!/bin/bash

Version=2.0

# Original source is from MigrateUserHomeToDomainAcct.sh
# Written by Patrick Gallagher – https://twitter.com/patgmac
# Guidance and inspiration from Lisa Davies:
# http://lisacherie.com/?p=239
# Modified by Rich Trouton
# Modified by MacGPT
# Modified by Kyle Ericson

# Added this script to convert all accounts and run silently


clear

listUsers="$(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 1000 {print $1}') FINISHED"
FullScriptName=`basename "$0"`
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

/bin/echo "********* Running $FullScriptName Version $Version *********"

RemoveAD(){

    # This function force-unbinds the Mac from the existing Active Directory domain
    # and updates the search path settings to remove references to Active Directory 

    searchPath=`/usr/bin/dscl /Search -read . CSPSearchPath | grep Active\ Directory | sed 's/^ //'`

    # Force unbind from Active Directory

    /usr/sbin/dsconfigad -remove -force -u none -p none
    
    # Deletes the Active Directory domain from the custom /Search
    # and /Search/Contacts paths
    
    /usr/bin/dscl /Search/Contacts -delete . CSPSearchPath "$searchPath"
    /usr/bin/dscl /Search -delete . CSPSearchPath "$searchPath"
    
    # Changes the /Search and /Search/Contacts path type from Custom to Automatic
    
    /usr/bin/dscl /Search -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
    /usr/bin/dscl /Search/Contacts -change . SearchPolicy dsAttrTypeStandard:CSPSearchPath dsAttrTypeStandard:NSPSearchPath
}

PasswordMigration(){

 
    AuthenticationAuthority=$(/usr/bin/dscl -plist . -read /Users/$netname AuthenticationAuthority)
    Kerberosv5=$(echo "${AuthenticationAuthority}" | xmllint --xpath 'string(//string[contains(text(),"Kerberosv5")])' -)
    LocalCachedUser=$(echo "${AuthenticationAuthority}" | xmllint --xpath 'string(//string[contains(text(),"LocalCachedUser")])' -)
    
    # Remove Kerberosv5 and LocalCachedUser
    if [[ ! -z "${Kerberosv5}" ]]; then
        /usr/bin/dscl -plist . -delete /Users/$netname AuthenticationAuthority "${Kerberosv5}"
    fi
    
    if [[ ! -z "${LocalCachedUser}" ]]; then
        /usr/bin/dscl -plist . -delete /Users/$netname AuthenticationAuthority "${LocalCachedUser}"
    fi
}



# Check for AD binding and offer to unbind if found.
if [[ "${check4AD}" = "Active Directory" ]]; then
	RemoveAD
	/bin/echo "AD binding has been removed."
	
fi

for netname in $listUsers; do
	if [ "$netname" = "FINISHED" ]; then
		/bin/echo "Finished converting users to local accounts"
		exit 0
	fi

	accounttype=$(/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')

	if [[ "$accounttype" = "Active Directory" ]]; then
		mobileusercheck=$(/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $1}' | tr -d '\n' | sed 's/^[^:]*: //' | sed s/\;/""/g)
		if [[ "$mobileusercheck" = "LocalCachedUser" ]]; then
			/usr/bin/printf "$netname has an AD mobile account.\nConverting to a local account with the same username and UID.\n"
		else
			/usr/bin/printf "The $netname account is not an AD mobile account\n"
			continue
		fi
	else
		/usr/bin/printf "The $netname account is not an AD mobile account\n"
		continue
	fi

	# Remove the account attributes that identify it as an Active Directory mobile account
	/usr/bin/dscl . -delete /users/$netname cached_groups
	/usr/bin/dscl . -delete /users/$netname cached_auth_policy
	/usr/bin/dscl . -delete /users/$netname CopyTimestamp
	/usr/bin/dscl . -delete /users/$netname AltSecurityIdentities
	/usr/bin/dscl . -delete /users/$netname SMBPrimaryGroupSID
	/usr/bin/dscl . -delete /users/$netname OriginalAuthenticationAuthority
	/usr/bin/dscl . -delete /users/$netname OriginalNodeName
	/usr/bin/dscl . -delete /users/$netname SMBSID
	/usr/bin/dscl . -delete /users/$netname SMBScriptPath
	/usr/bin/dscl . -delete /users/$netname SMBPasswordLastSet
	/usr/bin/dscl . -delete /users/$netname SMBGroupRID
	/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
	/usr/bin/dscl . -delete /users/$netname AppleMetaRecordName
	/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
	/usr/bin/dscl . -delete /users/$netname MCXSettings
	/usr/bin/dscl . -delete /users/$netname MCXFlags

	# Migrate password and remove AD-related attributes
	PasswordMigration

	# Refresh Directory Services
	if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then
		/usr/bin/killall DirectoryService
	else
		/usr/bin/killall opendirectoryd
	fi

	sleep 20

	accounttype=$(/usr/bin/dscl . -read /Users/"$netname" AuthenticationAuthority | head -2 | awk -F'/' '{print $2}' | tr -d '\n')
	if [[ "$accounttype" = "Active Directory" ]]; then
		/usr/bin/printf "Something went wrong with the conversion process.\nThe $netname account is still an AD mobile account.\n"
		exit 1
	else
		/usr/bin/printf "Conversion process was successful.\nThe $netname account is now a local account.\n"
	fi

	homedir=$(/usr/bin/dscl . -read /Users/"$netname" NFSHomeDirectory | awk '{print $2}')
	if [[ "$homedir" != "" ]]; then
		/bin/echo "Home directory location: $homedir"
		/bin/echo "Updating home folder permissions for the $netname account"
		/usr/sbin/chown -R "$netname" "$homedir"
	fi

	# Add user to the staff group on the Mac
	/bin/echo "Adding $netname to the staff group on this Mac."
	/usr/sbin/dseditgroup -o edit -a "$netname" -t user staff

	/bin/echo "Displaying user and group information for the $netname account"
	/usr/bin/id $netname
done
