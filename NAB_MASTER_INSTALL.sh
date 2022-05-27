#!/bin/bash

#Sudo Check
if [ `id -u` -eq 0 ]
then
        echo "Running as user with sudo privs :)"
else
        echo "Please run with standard (NON ROOT) user and sudo!"
        exit 1
fi

echo "###### CLONING LATEST FILES ######"
cd /opt/
sudo git clone https://github.com/FPS-Pentesting/dropbox.git
#echo "TO CLONE OPENVPN PRIVATE KEY YOU WILL NEED GITHUB LOGIN PASSWORD OR IF YOU USE 2FA YOU NEED A TOKEN AS THE PASSWORD: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token." 
sleep 1
#sudo git clone https://github.com/FPS-Pentesting/openvpn.git #Has not been created yet
cd /opt/dropbox
sudo chmod +x /opt/dropbox/*.sh


### Reboot Prompt
read -p "Do you want to install all tools? y/n: " prompt
if [[ "$prompt" =~ ^([yY][eE][sS]|[yY])$  ]]
  then
    echo "INSTALLING...."
  else
    echo "###### RUNNING ONLY INITIAL SETUP SCRIPT ######"
    sudo /opt/dropbox/dropbox_setup.sh
    exit 1
fi

echo "###### RUNNING DROPBOX SETUP SCRIPT ######"
sudo /opt/dropbox/dropbox_setup.sh

echo "###### RUNNING DROPBOX TOOLS SCRIPT ######"
sudo /opt/dropbox/dropbox_tools.sh

echo "###### RUNNING WIFI TOOLS SCRIPT ######"
sudo /opt/dropbox/wifi_tools.sh

#echo "###### CHANGING TO OPENVPN MASTER FILE ######"   #CONTAINS REBOOT PROMPT
#sudo /opt/dropbox/openvpn_change.sh

echo "###### INSTALLING PING CONNECTION SCRIPT ######"
sudo /opt/dropbox/install_ping.sh

echo "###### REBOOTING IN 5 SECONDS ######"   #CONTAINS REBOOT PROMPT
sleep 5
sudo /sbin/shutdown -r now #soft reboot

