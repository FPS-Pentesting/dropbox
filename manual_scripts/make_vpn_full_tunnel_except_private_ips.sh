#! /bin/bash

# All private IP traffic will be routed locally
# All external IP traffic will be routed over VPN

# Exception: 10.8.0.1/24 will still route over tun0
# This is REQUIRED for our connection to the NAB
# If the client has hosts in that range that need testing,
# we will need to come up with a special solution (this has never happened)

# Variables
LOCAL_GATEWAY=$(ip route | awk '/default/ {print $3}')

# Reset to Clean/Default State
sudo ip route del 0.0.0.0/1
sudo ip route del 128.0.0.0/1
sudo ip route del 10.0.0.0/8
sudo ip route del 172.16.0.0/12
sudo ip route del 192.168.0.0/16

# By default, route all traffic through the VPN tunnel
sudo ip route add 128.0.0.0/1 dev tun0
sudo ip route add 0.0.0.0/1 dev tun0

# Route all private ip traffic through local eth0
sudo ip route add 10.0.0.0/8 via $LOCAL_GATEWAY
sudo ip route add 172.16.0.0/12 via $LOCAL_GATEWAY
sudo ip route add 192.168.0.0/16 dev $LOCAL_GATEWAY

echo ""
echo "Errors that say 'File exists/No such process' are okay. That just means a route change was redundant."
