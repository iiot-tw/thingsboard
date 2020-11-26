log="igt_startup:"
echo "${log} begin"
#your code...
/neousys/tbClient-igtInfo.sh
/neousys/canConfig.sh 1000000
igt21 ttys2 485
chmod 666 /dev/ttyS2
#crontab */10 * * * * /neousys/tbClient-igtInfo.sh
igt21 do_en 1
chmod 666 /sys/class/gpio/gpio44/value
chmod 666 /sys/class/gpio/gpio45/value
chmod 666 /sys/class/gpio/gpio46/value
chmod 666 /sys/class/gpio/gpio47/value
#docker start igtnodered
echo "${log} end"
