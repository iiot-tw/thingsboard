wget https://github.com/iiot-tw/thingsboard/raw/master/igtInfo -O /neousys/igtInfo
chmod +x /neousys/igtInfo

wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
sudo apt install ./python3-thingsboard-gateway.deb -y

HOST=cloud.iiot.tw
TOKEN=$(sudo /neousys/igtInfo token)
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
    name: DI Connector
    type: di
    configuration: NT_IGT22.json
    class: CustomDIConnector
EOF

sudo cp /tmp/tb_gateway.yaml /etc/thingsboard-gateway/config/tb_gateway.yaml

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/custom_di_connector.py
sudo mkdir -p  /var/lib/thingsboard_gateway/extensions/di
sudo mv ./custom_di_connector.py  /var/lib/thingsboard_gateway/extensions/di

wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/NT_IGT22.json
sudo mv ./NT_IGT22.json /etc/thingsboard-gateway/config/
