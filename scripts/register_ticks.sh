#!/bin/bash
#
# this script:
# 1) registers tick scripts with existing kapacitor instance
#

if [ "$(id -u)" != "0" ]; then
   echo "ERROR - This script must be run as root" 1>&2
   exit 1
fi

cd /vagrant/ticks

export LANGUAGE=C
export LC_ALL=C

for script in `find /vagrant/ticks/ -type f -name '*.tick' | perl -ne 'if (m/\/vagrant\/ticks\/(.+)\.tick/){ print "$1\n"}'`
do
  sleep 1
  kapacitor define $script \
    -type "stream" \
    -dbrp telegraf.one_day_only \
    -tick $script.tick
  kapacitor enable $script
  kapacitor show $script
done
