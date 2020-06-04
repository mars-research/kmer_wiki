#!/bin/bash

a0="/sys/devices/system/cpu/cpufreq/policy\$X/scaling_governor"
a1="/sys/devices/system/cpu/cpufreq/policy\$X/scaling_max_freq"
a2="/sys/devices/system/cpu/cpufreq/policy\$X/scaling_min_freq"

for i in {0..19}
do
 b0=${a0/\$X/$i}
 b1=${a1/\$X/$i}
 b2=${a2/\$X/$i}
 echo performance > $b0
 echo 2200000 > $b1
 echo 2200000 > $b2
 cat $b0
 cat $b1
 cat $b2
done

