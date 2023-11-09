#!/usr/bin/env bash
# From https://www.inetdoc.net/guides/vm/vm.network.tun-tap.html
# To be called as:
# docker_network <ip> <netmask> <gateway>
# Where all parameters are container information:
# ip: IP address of the container under container's network
# netmask: netmask of the docker's container network
# gateway: gateway provided by docker to container
# For example:
# ./docker_network.sh 192.168.144.2 255.255.240.0 192.168.144.1

# Shutdown eth0
ifconfig eth0 0.0.0.0

# Setup tap0 device
ip tuntap add mode tap dev tap0
#ip addr ls tap0
ip link set dev tap0 up

# Create bridge
brctl addbr br0

# Add eth0+tap0 to the bridge
brctl addif br0 eth0
brctl addif br0 tap0

# Set ip and netmask of br0 to be same as was the eth0
ifconfig br0 $1 netmask $2 up

# Restore default route
route add default gw $3 br0
