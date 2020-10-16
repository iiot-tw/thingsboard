HOST="cloud.iiot.tw"
ACCESS_TOKEN=AM$(sudo ./igtA mac1)

# publish client side attribute
attr="{\
      \"MAC\":\"$(sudo ./igtA mac1)\"\
      }"
curl -v -X POST -d "{$attr}" http://$HOST/api/v1/$ACCESS_TOKEN/attributes --header "Content-Type:application/json"
