wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
sudo apt install ./python3-thingsboard-gateway.deb -y

HOST=cloud.iiot.tw
TOKEN=$(sudo ~/igtA token)
sudo sed -i "s,host: demo.thingsboard.io,host: $HOST,g" /etc/thingsboard-gateway/config/tb_gateway.yaml
sudo sed -i "s,accessToken: PUT_YOUR_GW_ACCESS_TOKEN_HERE,accessToken: $TOKEN,g" /etc/thingsboard-gateway/config/tb_gateway.yaml
