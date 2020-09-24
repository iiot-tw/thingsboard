ACCESS=$(hexdump -s96 -n16 -e '16/1 "%02X"' /sys/bus/i2c/devices/0-0050/eeprom)
sudo sed -i 's/PUT_YOUR_GW_ACCESS_TOKEN_HERE/${ACCESS}/' /etc/thingsboard-gateway/config/tb_gateway.yaml

#download config file
#sudo wget https://raw.githubusercontent.com/iiot-tw/thingsboard/master/CG_ESTHW50A2D.json -O /etc/thingsboard-gateway/config/CG_ESTHW50A2D.json
