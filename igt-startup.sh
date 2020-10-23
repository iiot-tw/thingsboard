log="igt_startup:"
echo "${log} begin"
#your code...
/neousys/usb.sh
/neousys/localip.sh
chmod 666 /dev/ttyS2
crontab */10 * * * * /neousys/tbClient-igtInfo.sh
echo "${log} end"
