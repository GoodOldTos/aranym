#!/usr/bin/env bash
# User should have downloaded Aranym data package at https://vision.goodoldtos.com/download/aranym_data.tar.xz
# But in case he did not, let's download and extract it
if [ ! -f /aranym/easymint/easymint_c.img ]
then
    echo "Aranym data NOT found, let's try to download it..."
    echo "**************************************************************"
    echo "* Note this has to chance to work only if this               *"
    echo "* Container has Internet access, if not please go to:        *"
    echo "* https://hub.docker.com/repository/docker/goodoldtos/aranym *"
    echo "* To follow instructions on how to install Aranym data       *"
    echo "**************************************************************"
    apt install -y wget xz-utils
    wget https://vision.goodoldtos.com/download/aranym_data.tar.xz
    tar -xvf aranym_data.tar.xz -C /aranym
    if [ ! -f /aranym/easymint/easymint_c.img ]
    then
      echo "FAIL to download Aranym data; please follow instructions at:"
      echo "https://hub.docker.com/repository/docker/goodoldtos/aranym"
    else
      echo "Aranym data successfully downloaded :-)"
      rm -f aranym_data.tar.xz
    fi
else
    echo "Aranym data is found, good news :-)"
fi
