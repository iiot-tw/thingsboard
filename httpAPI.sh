HOST="http://cloud.iiot.tw"
ACCESS_TOKEN=$(sudo get-uuid)

# publish client side attribute
attr="{\
      \"att1\":\"v1\"\
      }"
curl -v -X POST -d $attr http://$HOST/api/v1/$ACCESS_TOKEN/attributes --header "Content-Type:application/json"
