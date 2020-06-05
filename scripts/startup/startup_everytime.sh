#!/bin/bash

# disable hyperthreading
/proj/redshift-PG0/tarfiles/startup/ht.sh && 
echo "############################"
echo "[INFO] Hyperthreading disabled"
echo "############################"

# governor performance
cpupower frequency-set -g performance &&
cpupower frequency-set -u 2201000 &&
cpupower frequency-set -d 2201000 &&
echo "###########################################################"
echo "[INFO] Governor performance, max_freq = min_freq = 2201000"
echo "###########################################################"


# disable turbo-boost
echo 0 > /sys/devices/system/cpu/cpufreq/boost
echo "############################"
echo "[INFO] Turbo boost disabled"
echo "############################"

