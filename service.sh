#!/bin/bash
# myapp daemon
# chkconfig: 345 20 80
# description: myapp daemon
# processname: myapp

DAEMON_PATH={{ tmp_dir }}/

DAEMON="{{ java_home }}/bin/java -Dij.exceptionTrace=true -Dderby.system.home={{ db_path }} -jar {{ java_home }}/db/lib/derbyrun.jar server start -h {{ db_host }} -p {{ db_port }}"


NAME=derby
DESC="Starts a derby server instance"
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

case "$1" in
start)
	printf "%-50s" "Starting $NAME..."
	cd $DAEMON_PATH
	printf "%s\n" "command: $DAEMON"
	PID=`$DAEMON > /dev/null 2>&1 & echo $!`
	echo "Saving PID" $PID " to " $PIDFILE
        if [ -z $PID ]; then
            printf "%s\n" "Fail"
        else
            echo $PID > $PIDFILE
            printf "%s\n" "Ok"
        fi
;;
status)
        printf "%-50s" "Checking $NAME..."
        if [ -f $PIDFILE ]; then
            PID=`cat $PIDFILE`
            if [ -z "`ps axf | grep ${PID} | grep -v grep`" ]; then
                printf "%s\n" "Process dead but pidfile exists"
            else
                echo "Running"
            fi
        else
            printf "%s\n" "Service not running"
        fi
;;
stop)
        printf "%-50s" "Stopping $NAME"
            PID=`cat $PIDFILE`
            cd $DAEMON_PATH
        if [ -f $PIDFILE ]; then
            kill -9 $PID
            rm -rf {{ db_path }}/database/
            printf "%s\n" "Ok"
            rm -f $PIDFILE
        else
            printf "%s\n" "pidfile not found"
        fi
;;

restart)
  	$0 stop
  	$0 start
;;

*)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
