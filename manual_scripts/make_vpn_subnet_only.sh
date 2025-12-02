#!/bin/bash

# Only tun0 subnet traffic will be sent through the VPN (10.8.0.1/24)
# Most traffic will go through the local subnet (eth0)
# You won't need to add any specific routes to hit other client internal networks

# However, certain connections that you might not want to go through the client network will
# Ex.: Downloading updates for Kali would go over client's local network (which might be flagged/blocked)

# Reset to Clean/Default State
sudo ip route del 0.0.0.0/1
sudo ip route del 128.0.0.0/1
sudo ip route del 10.0.0.0/8
sudo ip route del 172.16.0.0/12
sudo ip route del 192.168.0.0/16

echo ""
echo "Errors that say 'RTNETLINK answers: No such process' are okay. That just means a route was already nonexistent."
