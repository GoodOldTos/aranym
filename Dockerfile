# This Dockerfile is used to build an headles vnc image based on Debian
FROM debian:latest

USER root
# For debug purpose: add some network tools
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt install -y net-tools traceroute iputils-ping iproute2 x11-apps openssh-client xvfb x11vnc fluxbox nftables aranym
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt install -y net-tools iputils-ping iproute2 xvfb x11vnc fluxbox nftables aranym

MAINTAINER GoodOldTOS "goodoldtos@free.fr"
ENV REFRESHED_AT 2023-12-08

### Environment
## Connection ports for controlling the UI:
# VNC port:5901
ENV STARTUPDIR=/app \
    ARANYM_RESOLUTION=1680x1050x16 \
    DISPLAY=:1 \
    VNC_PORT=5900 \
    ARANYM_MODE=JIT \
    ARANYM_SSH=22000 \
    ARANYM_FASTRAM=256

EXPOSE $VNC_PORT
EXPOSE 22

ADD ./src/ $STARTUPDIR/

# Create main folder for Aranym application (includes C and D images and host_fs)
RUN mkdir -p /aranym

# Create some optional folders that can be used to mount some generic shares
# Like for example photo/video shares on a NAS
RUN mkdir -p /mnt/photo
RUN mkdir -p /mnt/video
RUN mkdir -p /mnt/music
RUN mkdir -p /mnt/data
RUN mkdir -p /mnt/extra

# Create default password for opening a VNC session
RUN x11vnc -storepasswd aranym /aranym/x11vnc.pass


CMD ["bash", "/app/startup.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
