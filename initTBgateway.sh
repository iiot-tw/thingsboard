wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
sudo apt install ./python3-thingsboard-gateway.deb -y

HOST=cloud.iiot.tw
TOKEN=$(sudo ~/igtA token)
#sudo sed -i "s,host: demo.thingsboard.io,host: $HOST,g" /etc/thingsboard-gateway/config/tb_gateway.yaml
#sudo sed -i "s,accessToken: PUT_YOUR_GW_ACCESS_TOKEN_HERE,accessToken: $TOKEN,g" /etc/thingsboard-gateway/config/tb_gateway.yaml

echo "thingsboard:" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  host: demo.thingsboard.io" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  port: 1883" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  remoteConfiguration: false" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  security:" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "    accessToken: ${TOKEN}" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "storage:" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  type: memory" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  read_records_count: 100" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "  max_records_count: 100000" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "connectors:" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo
echo "  -" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "    name: DI Connector" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "    type: di" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "    configuration: custom_di.json" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
echo "    class: CustomDIConnector" >>　/etc/thingsboard-gateway/config/tb_gateway.yaml
