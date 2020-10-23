ipSafe=$(ip a | grep 'inet ' | \
       cut -f6 -d' ' | tr '\n' ' ' | \
       sed 's|\/|@|g' | sed 's| |\&|g')

echo "{\"localIp\":\"$ipSafe\", \
       \"localIpLastUpdate\":\"$(date)\" \
       \"modelName\":\"IGT-$(sudo /neousys/igtInfo model)\" \
      }" > /dev/shm/IP
if [ -f "/dev/shm/IP" ]; then
  curl -X POST http://cloud.iiot.tw/api/v1/$(sudo /neousys/igtInfo token)/attributes --header "Content-Type:application/json" -d @/dev/shm/IP
fi
