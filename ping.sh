#!/bin/bash

#Place this file in /opt/dropbox/ping.sh
#crontab -e
#add the following line (uncommented) and save
#0 * * * * /opt/dropbox/ping.sh

sleep 30   #Wait for boot and connect to VPN
VPN_SERVER='10.8.0.1'
count=$(ping -c 5 $VPN_SERVER | grep from* | wc -l) #attempt to ping 5 times

#If all 5 pings had no response, log time and reboot
if [ $count -eq 0 ]
then
  echo "$(date)" "!!!!!VPN SERVER" $VPN_SERVER "UNREACHABLE, REBOOTING!!!!!" >>/opt/dropbox/log/pingfaillog.txt
  sleep 1
  /sbin/shutdown -r now  #soft reboot
else
  echo "$(date) VPN Server ping successful :)" >>/opt/dropbox/log/pingfaillog.txt
fi
