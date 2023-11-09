#!/usr/bin/env bash
# Enable SSH on Mint
# To be called as:
# ssh_mint <ip_mint> <container_exposed_ssh_mint_port>
# Where:
# ip_mint: The IP address Atari machine in container's network
# container_exposed_ssh_mint_port: the port you want container to expose for accessing Mint by SSH
#                                  typically, this is the port exposed in docker-compose file
#                                  Note that Mint uses usual port 22 to listen to
# Example:
# ./ssh_mint 192.168.144.93 22000

/usr/sbin/nft add table ip nat

/usr/sbin/nft -- add chain ip nat prerouting { type nat hook prerouting priority -100 \; }
/usr/sbin/nft add chain ip nat postrouting { type nat hook postrouting priority 100 \; }
/usr/sbin/nft add rule ip nat prerouting tcp dport $2 dnat to "$1":22
/usr/sbin/nft add rule ip nat postrouting ip daddr $1 masquerade
