#!/bin/bash

# Almost all traffic will be sent through the VPN tunnel
# Only eth0 local subnet traffic will go through client's network
# If you need to hit other client subnets, you must add routing for them
# This is the default setup for a new NAB

sudo ip route add 128.0.0.0/1 via 10.8.0.1
sudo ip route add 0.0.0.0/1 via 10.8.0.1

echo ""
echo "Errors that say 'RTNETLINK answers: File exists' are okay. That just means a route already existed"
