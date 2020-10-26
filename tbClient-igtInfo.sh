ipSafe=$(ip a | grep 'inet ' | \
       cut -f6 -d' ' | tr '\n' ' ' | \
       sed 's|\/|@|g' | sed 's| |\&|g')

echo "{\"localIp\":\"$ipSafe\", \
       \"localIpLastUpdate\":\"$(date)\", \
       \"modelName\":\"IGT-$(sudo /neousys/igtInfo model)\", \
       \"serialNum\":\"$(sudo /neousys/igtInfo serial)\" \
      }" > /dev/shm/igtInfo.json
if [ -f "/dev/shm/igtInfo.json" ]; then
  curl -X POST http://cloud.iiot.tw/api/v1/$(sudo /neousys/igtInfo token)/attributes --header "Content-Type:application/json" -d @/dev/shm/igtInfo.json
fi
