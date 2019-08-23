#!/bin/bash
#Created by Kyle Ericson
#Date July 25th 2019
#You first have to download this script
#https://github.com/gregneagle/pycreateuserpkg

#Modify what you need to below
#Start Modify

Username="administrator"
Full_Name="Administrator"
Password="Replacewithyourpassword"
ID="504"
Company="Acemfg"
Home_Folder=("$Username")
consoleUser=$(stat -f %Su /dev/console)
Path2createuserpkgScript="/Users/$consoleUser/Documents/pycreateuserpkg-master"

#Stop Modify

#Run stuff
sudo $Path2createuserpkgScript/createuserpkg  -n $Username -f $Full_Name -u $ID -p $Password -H /Users/$Username --admin --autologin --hidden --version=1.0.0 --identifier=$Company /Users/$consoleUser/Desktop/$Company-$Username-AL.pkg

exit 0