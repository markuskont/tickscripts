#!/bin/bash
#
# this script:
# 1) registers tick scripts with existing kapacitor instance
#

if [ "$(id -u)" != "0" ]; then
   echo "ERROR - This script must be run as root" 1>&2
   exit 1
fi

cd /opt

export LANGUAGE=C
export LC_ALL=C

apt-get update && apt-get install -y git htop tmux

git clone https://github.com/influxdata/kapacitor /opt/kapacitor

CONFIG='
[udf.functions.pyavg]
   prog = "/usr/bin/python2"
   args = ["-u", "/opt/kapacitor/udf/agent/examples/moving_avg/moving_avg.py"]
   timeout = "10s"
   [udf.functions.pyavg.env]
       PYTHONPATH = "/opt/kapacitor/udf/agent/py/"
'

sed "/udf.functions]/a '$CONFIG'" /etc/kapacitor/kapacitor.conf
