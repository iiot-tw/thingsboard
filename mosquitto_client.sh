count=1

while true
do
  mosquitto_pub -d -m "{\"hb\":\"$count\"}" -h "demo.thingsboard.io" -t "v1/devices/me/telemetry" -u "$1"
  count=$((count+1))
  sleep 60
done
