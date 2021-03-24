# This script is created as an EXAMPLE for specific purpose on Neousys IGT series.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
# NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
# NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE AUTHORS SHALL NOT, UNDER ANY
# CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
# DAMAGES, FOR ANY REASON WHATSOEVER.

#!/bin/bash

if ! id | grep -q root; then
        echo "must be run as root"
        exit
fi

if [ "x$1" == "x" ] || [ "x$2" == "x" ]; then
  echo "Usage: $0 {thingsboard_host} {thingsboard_token}"
  exit 1
fi

HOST=$1
TOKEN=$2

#echo "HOST: $1"
#echo "TOKEN: $2"

if ! [ -a /neousys/igtInfo ]; then
  wget https://github.com/iiot-tw/thingsboard/raw/master/igtInfo -O /neousys/igtInfo
  chmod +x /neousys/igtInfo
fi

mv /neousys/igt-startup.sh /neousys/igt-startup.sh.old
wget https://raw.githubusercontent.com/iiot-tw/igt-22-dev/main/igt-startup.sh.IGT-22-DEV -O /neousys/igt-startup.sh
wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/tbClient-igtInfo.sh -O /neousys/tbClient-igtInfo.sh
sed -i "s/##PLACE_HOST##/${HOST}/" /neousys/tbClient-igtInfo.sh
sed -i "s/##PLACE_TOKEN##/${TOKEN}/" /neousys/tbClient-igtInfo.sh
chmod +x /neousys/*.sh

#if ! [ -a /opt/source/tbgateway/python3-thingsboard-gateway.deb ]; then
##Modbus seems not work properly on 2.5.1. check later
##wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
##deb is pre-downloaded
#  wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.0/python3-thingsboard-gateway.deb -O /opt/source/tbgateway/python3-thingsboard-gateway.deb
#fi 
#apt update
#apt install /opt/source/tbgateway/python3-thingsboard-gateway.deb -y

#TOKEN=$(sudo /neousys/igtInfo token)
SER=$(echo -e -n "\x$(printf "%x" $(($(sudo /neousys/igtInfo serial | cut -b1-2) +55)))$(sudo /neousys/igtInfo serial | cut -b3-)")
#sudo sed -i "s,host: demo.thingsboard.io,host: $HOST,g" /etc/thingsboard-gateway/config/tb_gateway.yaml
#sudo sed -i "s,accessToken: PUT_YOUR_GW_ACCESS_TOKEN_HERE,accessToken: $TOKEN,g" /etc/thingsboard-gateway/config/tb_gateway.yaml

cat << EOF > /tmp/tb_gateway.yaml
thingsboard:
  host: ${HOST}
  port: 1883
  remoteConfiguration: false
  security:
    accessToken: ${TOKEN}
storage:
  type: memory
  read_records_count: 100
  max_records_count: 100000
connectors:

  -
    name: IGT GPIO Connector
    type: igt_gpio
    configuration: NT_IGT22_IO.json
    class: IGT_GPIOConnector

  -
    name: Modbus Connector
    type: modbus
    configuration: NT_IGT22_TTYS2.json

EOF

mv /etc/thingsboard-gateway/config/tb_gateway.yaml /etc/thingsboard-gateway/config/tb_gateway.yaml.old
cp /tmp/tb_gateway.yaml /etc/thingsboard-gateway/config/tb_gateway.yaml

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/igt_gpio_connector.py
mkdir -p  /var/lib/thingsboard_gateway/extensions/igt_gpio
mv ./igt_gpio_connector.py  /var/lib/thingsboard_gateway/extensions/igt_gpio

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/NT_IGT22_IO.json
sed -i "s/IGT22_IO/IGT22_${SER}_IO/" NT_IGT22_IO.json
mv ./NT_IGT22_IO.json /etc/thingsboard-gateway/config/

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/TB55.json
sed -i "s/IGT_TB55/IGT22_${SER}_TTYS2/" TB55.json
mv ./TB55.json /etc/thingsboard-gateway/config/NT_IGT22_TTYS2.json

systemctl enable thingsboard-gateway.service
