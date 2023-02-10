#!/bin/bash

interface=wlan0
echo "Interface is set to $interface"
sleep 3

if [ `id -u` -eq 0 ]
then
        echo "Running as sudo user :)"
else
        echo "Please run with sudo!"
        exit 1
fi


#echo "Configuring wifi adapter"   # Moved to the end
#sudo ip link set $interface down
#sudo iw $interface set txpower fixed 3000
#sudo iw dev $interface set type monitor
#sudo ip link set $interface up

echo "Installing Tools..."
sudo apt update
sudo apt install realtek-rtl88xxau-dkms -y
sudo apt install airgeddon -y
sudo apt install bettercap hostapd-wpe isc-dhcp-server hostapd mdk4 beef-xss lighttpd -y   #Airgeddon supplemental tools
sudo apt install macchanger wifite python2.7 build-essential python2-dev libpcap-dev libssl-dev hcxdumptool hcxtools -y

echo "CLONING ADDITIONAL TOOLS INTO /opt"
cd /opt

echo "Installing python2 pip..."
mkdir /opt/pip
cd /opt/pip
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
python get-pip.py
pip2 install --upgrade setuptools
	
echo "Downloading pyrit..."
mkdir /opt/pyrit
cd /opt/pyrit
wget https://github.com/JPaulMora/Pyrit/releases/download/v0.5.0/Pyrit-v0.5.0.zip
unzip Pyrit-v0.5.0.zip
		
echo "Installing Pyrit..."
cd /opt/pyrit
pip2 install psycopg2-binary
pip2 install scapy   # if fail sudo apt-get install python-scapy
sudo python setup.py clean build install

### Redundant Update befor Eaphammer install ###
sudo apt -y update && sudo apt -y upgrade

### Add eaphammer tools ####
echo "INSTALLING EAP HAMMER!!!"
#sudo apt install eaphammer -y  #This package is broken
cd /opt/
sudo git clone https://github.com/s0lst1c3/eaphammer.git
pip3 install pem
cd /opt/eaphammer
echo "y" | sudo ./kali-setup

echo "Setting adapter to monitor mode!!!"
sudo ip link set $interface down; sudo iw $interface set txpower fixed 3000; sudo iw dev $interface set type managed; sudo ip link set $interface up

echo "Start test with (sudo wifite -i $interface)"
echo "CONFIGURE eaphammer with (sudo ./eaphammer --cert-wizard interactive)
