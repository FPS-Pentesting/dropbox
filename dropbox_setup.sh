#!/bin/bash

username=pentest

# Make install noninteractive (don't prompt the user to restart services)
export DEBIAN_FRONTEND=noninteractive

echo "Set new sudo password for $username user before running this script!"
sleep 1

#Sudo Check
if [ `id -u` -eq 0 ]
then
        echo "Running as user with sudo privs :)"
else
        echo "Please run with standard (NON ROOT) user and sudo!"
        exit 1
fi

echo "Disabling Sleep"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Please enter the machine name which is also the name of the openvpn file without the extension"
read -p 'Hostname: ' hostname

filename=$hostname.ovpn

# if ovpn file does not exist then exit
if [ ! -f /home/pentest/$filename ]
then
    echo "$filename not found. Exiting!"
    exit 1
else
    echo "File found. Copying now..."
fi

sudo cp /home/pentest/$filename /etc/openvpn/openvpn.conf
#sudo rm /opt/openvpn/*
sudo systemctl enable openvpn
echo "Copied and enabled dropbox openvpn file!"
sudo rm /home/pentest/$filename

#echo "Please enter new hostname (companyname):"
#read hostname
sudo hostnamectl set-hostname $hostname
sed -i "s/127.0.1.1.*/127.0.1.1\t$hostname/g" /etc/hosts
echo "Hostname set to $hostname"

echo "UPDATING"
sudo apt update && sudo apt upgrade -y

echo "Installing and enabling RDP"
sudo apt install xrdp -y
service xrdp start
service xrdp-sesman start
update-rc.d xrdp enable

echo "Enabling SSH"
sudo systemctl enable ssh.service
systemctl start ssh.service

echo "Enabling NTP"
sudo timedatectl set-timezone America/New_York
sudo systemctl enable ntp.service
sudo systemctl start ntp.service

echo "Configuring XRDP for better Performance"
sudo /opt/dropbox/xrdp_performance_tweaks.sh

echo "Configuring zsh for better history"
sudo /opt/dropbox/setup_custom_zshrc.sh

echo "Installing and configuring auditd"
sudo /opt/dropbox/setup_auditd.sh

echo "Cleaning Up..."
sudo apt autoclean
sudo apt -y autoremove

echo "RECOMMEND REBOOT AFTER SCRIPT FINISHES……"
sleep 3
