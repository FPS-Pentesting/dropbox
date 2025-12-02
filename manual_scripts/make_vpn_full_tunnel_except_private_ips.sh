#! /bin/bash

# All private IP traffic will be routed locally
# All external IP traffic will be routed over VPN

# Exception: 10.8.0.1/24 will still route over tun0
# This is REQUIRED for our connection to the NAB
# If the client has hosts in that range that need testing,
# we will need to come up with a special solution (this has never happened)

# Reset to Clean/Default State
sudo ip route del 0.0.0.0/1
sudo ip route del 128.0.0.0/1
sudo ip route del 10.0.0.0/8
sudo ip route del 172.16.0.0/12
sudo ip route del 192.168.0.0/16

# By default, route all traffic through the VPN tunnel
sudo ip route add 128.0.0.0/1 via 10.8.0.1
sudo ip route add 0.0.0.0/1 via 10.8.0.1

# Route all private ip traffic through local eth0
sudo ip route add 10.0.0.0/8 dev eth0
sudo ip route add 172.16.0.0/12 dev eth0
sudo ip route add 192.168.0.0/16 dev eth0

# This rule should always already exist (it is necessary for our connection to the NAB)
sudo ip route add 10.8.0.0/24 dev tun0

echo ""
echo "Errors that say 'RTNETLINK answers: File exists' are okay. That just means a route already existed"
