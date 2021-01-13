if ! [ -a /opt/source/tbgateway/python3-thingsboard-gateway.deb ]; then
#Modbus seems not work properly on 2.5.1. check later
#wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.1/python3-thingsboard-gateway.deb
#deb is pre-downloaded
  wget https://github.com/thingsboard/thingsboard-gateway/releases/download/2.5.0/python3-thingsboard-gateway.deb -O /opt/source/tbgateway/python3-thingsboard-gateway.deb
fi 
apt update
apt install /opt/source/tbgateway/python3-thingsboard-gateway.deb -y

## thingsboard-gateway 2.5.0 seems to have problem running modbus immediately after first run
## "sude systemctl restart thingsboard-gateway" will recover this.
## Just install pymodbus beforehand for better user experience
sudo pip3 install pymodbus
