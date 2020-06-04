#!/bin/bash

############################################
# - Run as sudo
############################################

# chown 
chown -R $USER /local/devel/ &&
echo "################################"
echo "[INFO] chown-ed /local/devel/"
echo "################################"

# update ppas
apt update -qq &&

# install libs
apt install -y -qq libnuma-dev && 
apt install -y -qq libtbb-dev &&
apt install -y -qq libboost-all-dev && 
apt install -y -qq linux-tools-$(uname -r) && 
apt install -y -qq cmake &&
apt install -y -qq htop &&
echo "#################################"
echo "[INFO] Installing libs ... DONE"
echo "#################################"

# disable intel pstate
sed -i -E 's!(GRUB_CMDLINE_LINUX_DEFAULT=")(.*)(")!\1intel_pstate=disable intel_idle.max_cstate=1\3!' /etc/default/grub &&
echo "###########################################"
echo "[INFO] intel pstate disable, max_cstate = 1"
echo "###########################################"
update-grub &&
reboot

