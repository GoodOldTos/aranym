#!/bin/bash
# Let's move to app folder
cd /app

# Fix ARANYM_RESOLUTION if required and define VNC_RESOLUTION
source resolutions.sh
echo 'Will use:'
echo 'ARANYM_RESOLUTION=' $ARANYM_RESOLUTION
echo 'VNC_RESOLUTION   =' $VNC_RESOLUTION
Xvfb $DISPLAY -screen 0 $VNC_RESOLUTION &
sleep 1
fluxbox &
sleep 1
x11vnc -noxdamage -noxfixes -forever -rfbauth /aranym/x11vnc.pass &
sleep 1
setxkbmap $VNC_KEYBOARD
#x11vnc -noxdamage -forever -rfbauth /etc/x11vnc.pass &
#x11vnc -xkb -noxrecord -noxfixes -noxdamage -rfbauth /etc/x11vnc.pass &
#x11vnc -noxdamage -rfbauth /etc/x11vnc.pass &

# Setup container network to enable Mint accessing it
# 2 steps:
# 1) Create tap0 device for Aranym to expose eth0 in Mint with access to container's network
# 2) Instruct Mint of network settings and port forwarding from container
# 3) Modify Aranym config file at /aranym/config to tell Aranym about Atari IP, netmask and host IP (gateway actually)
# For 1), we need:
# - container_ip: the IP address of the container (bridged by docker0)
# - container_netmask: its netmask
# - container_gateway: the gateway provided by docker to reach local network/Internet
# For 2), we need:
# - atari_ip: the IP (in container's network) we want Mint to use, it has to be not yet used of cause
# - atari_nat_ssh_port: the port (the one in docker-compose) exposed by the container to reach Mint by SSH from the outside
# For 3), we need:
# - atari_ip
# - container_netmask
# - container_gateway
# 1)
container_ip=$(ifconfig eth0 | awk '/netmask/{ print $2;} ')
container_netmask=$(ifconfig eth0 | awk '/netmask/{ print $4;} ')
container_gateway=$(ip route show 0.0.0.0/0 dev eth0 | cut -d\  -f3)
echo 'Container IP:' $container_ip
echo 'Container netmask:' $container_netmask
echo 'Container Gateway:' $container_gateway
echo 'Setting-up tap0 in container...'
./docker_network.sh $container_ip $container_netmask $container_gateway

# 2)
# Find a feee IP within container network
# Make it simple: try some IPs after container's IP
# Hoping netmask is not too weird
last_digit=$(echo $container_ip | awk -F"." '{print $4;}')
for i in $(seq $last_digit 254)
do
  test_ip=${container_ip%.*}."$i"
  ping $test_ip -c2 > /dev/null
  if [[ $? -eq 0 ]]
  then
    echo $test_ip 'is already used.'
  else
    echo $test_ip 'is free, will be used for Atari IP.'
    atari_ip=$test_ip
   break
  fi
done
./ssh_mint.sh $atari_ip $ARANYM_SSH

# 3)
# Update AtariIP, Netmask and HostIP in Aranym config file
sed -i "/AtariIP =/c\AtariIP = $atari_ip" /aranym/config
sed -i "/Netmask =/c\Netmask = $container_netmask" /aranym/config
sed -i "/HostIP =/c\HostIP = $container_gateway" /aranym/config


# Update fvdi.sys to cope with VNC_RESOLUTION
#echo 'Skipping FVDI.SYS update for now...'
./fvdi.sh $ARANYM_RESOLUTION /aranym/host_fs/xsys/fvdi.sys

# Now tell Aranym how much RAM our Atari VM has
echo 'Setting FastRAM to' $ARANYM_FASTRAM 'MB'
sed -i "/FastRAM =/c\FastRAM = $ARANYM_FASTRAM" /aranym/config

# Let's move to aranym folder
cd /aranym

case "$ARANYM_MODE" in
 "JIT")
  echo "Running Aranym in JIT mode"
  ./setup_ara_jit.sh
  ara_bin=aranym-jit
  ;;

 "MMU")
  echo "Running Aranym in MMU mode"
  ara_bin=aranym-mmu
  ;;

 *)
  echo "Running Aranym in usual mode"
  ara_bin=aranym
  ;;
esac

# Remove any previous coredump due to unclear disconnection
rm -f /aranym/core

/usr/bin/$ara_bin -c config
if [[ $? -eq 0 ]]
then
  echo 'Aranym exited normally'
else
  echo 'Error running Aranym; giving it a new try...'
  rm -f /aranym/core
  if [[ $$ARANYM_MODE == "JIT" ]]
  then
    echo 'Setting-up memoffset for JIT again...'
    ./setup_ara_jit.sh
  fi
  /usr/bin/$ara_bin -c config
fi

# When Aranym exists, stop container (tail commented out)
#tail -f /dev/null
