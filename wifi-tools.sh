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

echo "Configuring wifi adapter"
sudo ip link set $interface down
sudo iw dev $interface set type monitor
sudo ip link set $interface up

echo "Setting TX to MAX Power!!!!!!!!"
sudo iw $interface set txpower fixed 3000

echo "Installing Tools..."
sudo apt update
sudo apt install macchanger wifite python2.7 build-essential python-dev libpcap-dev libssl-dev hcxdumptool hcxtools -y

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
python setup.py clean build install

echo "Setting adapter to monitor mode!!!"
sudo ip link set wlan0 down; sudo iw dev wlan0 set type monitor; sudo ip link set wlan0 up

echo "Start test with (sudo wifite -i <INTERFACE>)"

### Add eaphammer tools ####








