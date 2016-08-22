#!/bin/bash
#
# this script:
# 1) installs telegraf
# 2) sets influxdb to $1
#

if [ "$(id -u)" != "0" ]; then
   echo "ERROR - This script must be run as root" 1>&2
   exit 1
fi

service telegraf stop

MASTER=$1
IP=$(ifconfig eth1 2>/dev/null|grep 'inet addr'|cut -f2 -d':'|cut -f1 -d' ')
HOSTNAME=$(hostname -f)

echo "installing telegraf on ${IP} ${HOSTNAME} setting influxdb to ${MASTER}..."


TLGF=0.13.2
INSTALL_DIR=/provision

mkdir -p ${INSTALL_DIR}/telegraf
cd ${INSTALL_DIR}/telegraf
if [ ! -f "telegraf_${TLGF}_amd64.deb" ]; then
            wget -4 wget https://dl.influxdata.com/telegraf/releases/telegraf_${TLGF}_amd64.deb
fi
if [ ! -f "telegraf_${TLGF}_amd64.deb" ]; then
    echo "$(date) ${NAME} $0[$$]: {telegaf: {status:ERROR, msg: missing telegraf_${TLGF}_amd64.deb}"
    exit -1
else
  echo -e "Y"|dpkg -i telegraf_${TLGF}_amd64.deb > /dev/null
  #  urls = ["http://localhost:8086"] # required
  sed -i -e 's,http://localhost,http://'${MASTER}',g' /etc/telegraf/telegraf.conf
  #   interval = "10s"
  sed -i -e 's,interval = "10s",interval = "1s",g' /etc/telegraf/telegraf.conf
  # flush_interval = "10s"
  sed -i -e 's,flush_interval = "1s",flush_interval = "60s",g' /etc/telegraf/telegraf.conf
  # use correct retention policy, measurements may not show up otherwise
  sed -i -e 's,retention_policy = "default",retention_policy = "one_day_only",g' /etc/telegraf/telegraf.conf
  echo "[[inputs.net]]" >> /etc/telegraf/telegraf.conf
  echo "[[inputs.netstat]]" >> /etc/telegraf/telegraf.conf

  service telegraf restart
fi
