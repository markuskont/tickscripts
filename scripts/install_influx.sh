#!/bin/bash
#
# this script:
# 1) installs influxdb
# 2) sets influxdb to $1
#

if [ "$(id -u)" != "0" ]; then
   echo "ERROR - This script must be run as root" 1>&2
   exit 1
fi

BIND=$1
IP=$(ifconfig eth1 2>/dev/null|grep 'inet addr'|cut -f2 -d':'|cut -f1 -d' ')
HOSTNAME=$(hostname -f)

echo "installing influxdb on ${IP} ${HOSTNAME} setting bind to ${BIND}..."

INSTALL_DIR=/provision

INFLX="0.13.0"

mkdir -p ${INSTALL_DIR}/influxdb
cd ${INSTALL_DIR}/influxdb
if [ ! -f "influxdb_${INFLX}_amd64.deb" ]; then
   wget -q https://dl.influxdata.com/influxdb/releases/influxdb_${INFLX}_amd64.deb
fi
if [ ! -f "influxdb_${INFLX}_amd64.deb" ]; then
  echo "$(date) ${NAME} $0[$$]: {influxdb: {status:ERROR, msg: missing influxdb_${INFLX}_amd64.deb}"
  exit -1
else
  echo -e "Y"|dpkg -i influxdb_${INFLX}_amd64.deb 2>&1 > /dev/null
  service influxdb restart
  sleep 1
  #prepare for telegraf
  curl -s -G http://localhost:8086/query --data-urlencode "q=DROP DATABASE telegraf"
  sleep 1
  curl -s -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE telegraf"
  curl -s -G http://localhost:8086/query --data-urlencode "q=CREATE RETENTION POLICY one_day_only ON telegraf DURATION 1d REPLICATION 1 DEFAULT"
  #sed -i -e 's,localhost,'${METRICS_SERVER}',g' /etc/influxdb/influxdb.conf

  #service telegraf restart
fi
netstat -lntpe | grep influx
