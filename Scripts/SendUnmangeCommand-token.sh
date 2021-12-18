#!/bin/bash

##########################################################################################
##
##Copyright (c) 2019 Jamf.  All rights reserved.
##
##      Redistribution and use in source and binary forms, with or without
##      modification, are permitted provided that the following conditions are met:
##              * Redistributions of source code must retain the above copyright
##                notice, this list of conditions and the following disclaimer.
##              * Redistributions in binary form must reproduce the above copyright
##                notice, this list of conditions and the following disclaimer in the
##                documentation and#or other materials provided with the distribution.
##              * Neither the name of the Jamf nor the names of its contributors may be
##                used to endorse or promote products derived from this software without
##                specific prior written permission.
##
##      THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
##      EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
##      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##      DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
##      DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
##      (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
##      LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
##      ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
##      SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##########################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, Professional Services Team. For more
#       information or support for this script, please contact your JAMF Software Account Manager.
#
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME - apiMDM_remove.sh
# 
# DESCRIPTION - Script is used to remove MDM from macOS clients 10.13 (High Sierra) and later.
#               Parameters passed to the script include a Jamf server api token and 
#               optionally the Jamf server URL in the form: https://FQDN:port/.
#
#               The jamf user aaccount must have at least computer create and read (JSS Objects) 
#               along with Send Computer Unmanage Command (JSS Actions).
# 	
####################################################################################################
#
# HISTORY
#
#	Version: 1.0
#
#	- Created by Leslie Helou, Professional Services Engineer, JAMF Software on December 12, 2017
#
#	Version: 1.1
#
#	- Matthew Phillips added Tokenized API access in $4. username and password parameters removed.
#
####################################################################################################


## api account with computer create and read (JSS Objects), Send Computer Unmanage Command (JSS Actions)

if [ "$4" != "" ];then
	token="$4"
else
	echo "token not provided. exiting."
	exit 1
fi


if [ "$5" != "" ];then
	server="$5"
	echo "jamf URL not provided. getting from client plist."
else
	## get current Jamf server
	server=$(defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
fi

## ensure the server URL ends with a /
strLen=$((${#server}-1))
lastChar="${server:$strLen:1}"
if [ ! "$lastChar" = "/" ];then
    server="${server}/"
fi


###Check API Access
apiCheck=$(/usr/bin/curl -X GET -H "Authorization: Basic ${token}" ${server}JSSResource/accounts | /usr/bin/grep -o "Unauthorized")
if [ "$apiCheck" == "Unauthorized" ];then
	/bin/echo "Error with API token. Unauthorized Access."
	exit 1
fi
	

## get unique identifier for machine
udid=$(system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }')

## get computer ID from Jamf server
compId=$(/usr/bin/curl -X GET -H "Authorization: Basic ${token}" \
		${server}JSSResource/computers/udid/${udid}/subset/general \
		"Accept: application/xml" | \
		/usr/bin/xpath "//computer/general/id/text()" 2>/dev/null)
if [ "$compId" == "" ]; then
	/bin/echo "Error in xpath or device record not found"
	exit 1
fi

## send unmanage command
curl -X POST -H "Authorization: Basic ${token}" ${server}JSSResource/computercommands/command/UnmanageDevice/id/${compId}

exit