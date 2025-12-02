#!/bin/bash

# Almost all traffic will be sent through the VPN tunnel
# Only eth0 local subnet traffic will go through client's network
# If you need to hit other client subnets, you must add routing for them
# This is the default setup for a new NAB

# Reset to Clean/Default State
sudo ip route del 0.0.0.0/1
sudo ip route del 128.0.0.0/1
sudo ip route del 10.0.0.0/8
sudo ip route del 172.16.0.0/12
sudo ip route del 192.168.0.0/16

# Route traffic through VPN tunnel by default
sudo ip route add 128.0.0.0/1 via 10.8.0.1
sudo ip route add 0.0.0.0/1 via 10.8.0.1

# There should already be a rule to allow eth0 traffic to not be tunneled
# Ex.: 10.50.0.0/24 dev eth0 proto kernel scope link src 10.50.0.37 metric 100

echo ""
echo "Errors that say 'File exists/No such process' are okay. That just means a route change was redundant."
