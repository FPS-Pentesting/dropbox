#!/bin/bash

# Make install noninteractive (don't prompt the user to restart services)
export DEBIAN_FRONTEND=noninteractive

echo "Set new sudo password for kali user before running this script!"
sleep 1

if [ `id -u` -eq 0 ]
then
        echo "Running as sudo user :)"
else
        echo "Please run with sudo!"
        exit 1
fi

## Brute force login tools
sudo apt install brutespray -y

## AD Testing Tools
sudo apt install ldapscripts bloodhound veil -y

### Install exploit compiling packages
sudo apt install mingw-w64 -y
sudo apt install g++-multilib -y

## Remove dos NSE Scripts
sudo rm /usr/share/nmap/scripts/broadcast-avahi-dos.nse
sudo rm /usr/share/nmap/scripts/smb-vuln-regsvc-dos.nse

## Additional Random Tools
sudo apt install seclists curl enum4linux eyewitness feroxbuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf -y
sudo apt install gedit nfs-common python3-pip libimage-exiftool-perl -y


echo "CLONING TOOLS INTO /opt"
cd /opt

echo "INSTALLING Impacket..."
git clone https://github.com/SecureAuthCorp/impacket.git

echo "INSTALLING Mitm6..."
git clone https://github.com/fox-it/mitm6.git

echo "INSTALLING PowerTools..."
git clone https://github.com/PowerShellMafia/PowerSploit.git

echo "INSTALLING SecLists..."
git clone https://github.com/danielmiessler/SecLists.git

echo "INSTALLING PEASS-ng..."
git clone https://github.com/carlospolop/PEASS-ng.git

echo "INSTALLING Wifi Drivers..."
sudo apt install realtek-rtl88xxau-dkms -y

echo "Cleaning Up..."
sudo apt autoclean
sudo apt autoremove -y

sleep 1
echo "Please manually update Searchsploit DB (searchsploit --update)"
#searchsploit --update
sleep 1
echo "OPENING LINKS FOR OTHER TOOLS!"
sleep 1
echo "https://portswigger.net/burp/documentation/desktop/getting-started"
echo "https://www.tenable.com/downloads/nessus"
echo "https://addons.mozilla.org/en-US/firefox/addon/wappalyzer/"
echo "https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-basic/"
