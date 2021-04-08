#!/bin.zsh
# Deploys latest Splashtop Streamer 
# Use Parameter $4 in Jamf for your org ID from Splashtop
# Created by Kyle Ericson
# Version 1.0
# March 26 2021

curl -L https://support-splashtopbusiness.splashtop.com/hc/en-us/article_attachments/360065327792/Deploy_splashtop_streamer.sh.zip -o /tmp/Deploy_splashtop_streamer.sh.zip

unzip /tmp/Deploy_splashtop_streamer.sh.zip -d /tmp/Deploy_splashtop_streamer.sh

mv /tmp/Deploy_splashtop_streamer.sh /tmp/Splash

curl -L  https://my.splashtop.com/csrs/mac -o /tmp/Splash/splash.dmg

sh /tmp/Splash/Deploy_splashtop_streamer.sh -i "/tmp/Splash/splash.dmg" -d $4  -w 0 -s 0

exit 0