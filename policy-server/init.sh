# flash policy daemon auto-start

RUNNER="/usr/bin/python"
RUNOPTS="/home/dan/amqp/amqp-js/policy-server/server.py --file=/home/dan/amqp/amqp-js/policy-server/crossdomain.xml"

case $1 in
start)
		echo "Starting flash policy server"
		start-stop-daemon --start --background  --exec $RUNNER -- $RUNOPTS
		;;
stop)
		echo "Stopping flash polcity server"
		start-stop-daemon --stop --oknodo --exec $RUNNER -- $RUNOPTS
		;;
restart)
		echo "Restarting flash policy server"
		start-stop-daemon --stop --oknodo --exec $RUNNER -- $RUNOPTS
		start-stop-daemon --start --background --exec $RUNNER -- $RUNOPTS
		;;
esac
exit 0
