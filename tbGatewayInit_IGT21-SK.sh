wget https://github.com/iiot-tw/thingsboard/raw/master/igtInfo -O /neousys/igtInfo
chmod +x /neousys/igtInfo

mv /neousys/igt-startup.sh /neousys/igt-startup.sh.old
wget https://github.com/iiot-tw/thingsboard/raw/master/tbClient-igtInfo.sh -O /neousys/tbClient-igtInfo.sh
wget https://github.com/iiot-tw/thingsboard/raw/master/igt-startup_IGT21-SK.sh -O /neousys/igt-startup.sh
wget https://raw.githubusercontent.com/iiot-tw/igt-20-utils/master/igtutil-canConfig.sh -O /neousys/canConfig.sh
chmod +x /neousys/*.sh

#Modbus seems not work properly on 2.5.1. check later
#wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
#deb is pre-downloaded
#wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.0/python3-thingsboard-gateway.deb -O /opt/source/tbgateway/python3-thingsboard-gateway.deb
apt update
apt install /opt/source/tbgateway/python3-thingsboard-gateway.deb -y

HOST=cloud.iiot.tw
TOKEN=$(sudo /neousys/igtInfo token)
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
    configuration: NT_IGT21.json
    class: IGT_GPIOConnector
  -
    name: Modbus Connector
    type: modbus
    configuration: TB55.json
  -
    name: CAN Connector
    type: can
    configuration: NT_IGT21_CAN_demo.json    
EOF

cp /tmp/tb_gateway.yaml /etc/thingsboard-gateway/config/tb_gateway.yaml

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/igt_gpio_connector.py
mkdir -p  /var/lib/thingsboard_gateway/extensions/igt_gpio
mv ./igt_gpio_connector.py  /var/lib/thingsboard_gateway/extensions/igt_gpio

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/NT_IGT21.json
sed -i "s/IGT21_IO/IGT21_${SER}_IO/" NT_IGT21.json
mv ./NT_IGT21.json /etc/thingsboard-gateway/config/

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/TB55.json
sed -i "s/IGT_TB55/IGT21_${SER}_TB55/" TB55.json
mv ./TB55.json /etc/thingsboard-gateway/config/

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/NT_IGT21_CAN_demo.json
sed -i "s/IGT21_CAN/IGT21_${SER}_CAN/" NT_IGT21_CAN_demo.json
mv ./NT_IGT21_CAN_demo.json /etc/thingsboard-gateway/config/


wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/CG_ESTHW50A2D.json
sed -i "s/CG_ESTHW50A2D-00/IGT21_${SER}_TB55/" CG_ESTHW50A2D.json
mv ./CG_ESTHW50A2D.json /etc/thingsboard-gateway/config/
