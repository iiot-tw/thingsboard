ipSafe=$(ip a | grep 'inet ' | \
       cut -f6 -d' ' | tr '\n' ' ' | \
       sed 's|\/|@|g' | sed 's| |\&|g')

echo "{\"localIp\":\"$ipSafe\", \
       \"localIpLastUpdate\":\"$(date)\", \
       \"upTime\":\"$(uptime)\", \
       \"modelName\":\"IGT-$(sudo /neousys/igtInfo model)\", \
       \"serialNum\":\"$(sudo /neousys/igtInfo serial)\" \
      }" > /dev/shm/igtInfo.json
if [ -f "/dev/shm/igtInfo.json" ]; then
  curl -X POST http://##PLACE_HOST##/api/v1/##PLACE_TOKEN##/attributes --header "Content-Type:application/json" -d @/dev/shm/igtInfo.json
fi
