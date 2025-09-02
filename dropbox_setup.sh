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

### Setup OpenVPN
# if ovpn file does not exist then exit
if [ ! -f /home/pentest/$filename ]
then
    echo "$filename not found. Exiting!"
    exit 1
else
    echo "File found. Copying now..."
fi

service_name="$hostname"
sudo mv "/home/pentest/$filename" "/etc/openvpn/${service_name}.conf"
# Make our configfile immutable to protect it
sudo chattr +i "/etc/openvpn/${service_name}.conf"

# Enable and start the corresponding instance service
sudo systemctl enable "openvpn@${service_name}"
sudo systemctl start "openvpn@${service_name}"

# Create systemd override:
# - OpenVPN Service will wait for Networking to start
# - OpenVPN Service will auto-restart if it fails
sudo systemctl edit "openvpn@${service_name}" --force --full <<'EOF'
[Unit]
After=network-online.target
Wants=network-online.target

[Service]
Restart=always
RestartSec=10
EOF

# Reload systemd to apply changes
sudo systemctl daemon-reload
sudo systemctl restart "openvpn@${service_name}"

# Prevent OpenVPN package from being upgraded or removed
# This might be overkill, but if we lose access to a remote NAB, we are somewhat dead-in-the-water
sudo apt-mark hold openvpn

echo "Configured and enabled OpenVPN service: openvpn@${service_name} with auto-restart and network wait"

### Change Hostname
sudo hostnamectl set-hostname $hostname
sed -i "s/127.0.1.1.*/127.0.1.1\t$hostname/g" /etc/hosts
echo "Hostname set to $hostname"

### Update, Upgrade, and install specific tooling
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

### Run Child setup scripts
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
