# This Dockerfile is used to build an headless Aranym application from an image based on Debian
FROM debian:latest

USER root
# For debug purpose: add some network tools
#RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt install -y net-tools traceroute iputils-ping iproute2 x11-apps openssh-client xvfb x11vnc fluxbox nftables aranym
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && apt install -y net-tools iputils-ping iproute2 xvfb x11vnc fluxbox nftables aranym

MAINTAINER GoodOldTOS "goodoldtos@free.fr"
ENV REFRESHED_AT 2023-11-07

### Environment
## Connection ports for controlling the UI:
# VNC port:5900
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

RUN mkdir -p /aranym
# Create default password for opening a VNC session
RUN x11vnc -storepasswd aranym /aranym/x11vnc.pass


CMD ["bash", "/app/startup.sh"]
#ENTRYPOINT ["tail", "-f", "/dev/null"]
