if [ "x$1" == "x" ] || [ "x$2" == "x" ]; then
  echo "Usage: $0 {thingsboard_host} {thingsboard_token}"
  exit 1
fi

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
  curl -X POST http://$1/api/v1/$2/attributes --header "Content-Type:application/json" -d @/dev/shm/igtInfo.json
fi
