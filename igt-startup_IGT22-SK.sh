log="igt_startup:"
echo "${log} begin"
#your code...
/neousys/usb.sh
/neousys/tbClient-igtInfo.sh
chmod 666 /dev/ttyS2
crontab */10 * * * * /neousys/tbClient-igtInfo.sh
igt22 do_en 1
chmod 666 /sys/class/gpio/gpio111/value
chmod 666 /sys/class/gpio/gpio110/value
chmod 666 /sys/class/gpio/gpio112/value
chmod 666 /sys/class/gpio/gpio113/value
chmod 666 /sys/class/gpio/gpio117/value
chmod 666 /sys/class/gpio/gpio104/value
chmod 666 /sys/class/gpio/gpio7/value
chmod 666 /sys/class/gpio/gpio103/value
#docker start igtnodered
echo "${log} end"
