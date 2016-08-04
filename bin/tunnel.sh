#!/bin/sh

function tunnel_start {
    ssh -f PASSTHROUGH_HOST "ssh -fN -L ${1}:TARGET_HOST:22 TARGET_USER@TARGET_HOST;" 2> /dev/null;
    ssh -fN -L ${1}:127.0.0.1:${1} PASSTHROUGH_HOST 2> /dev/null;
}

function tunnel_stop {
    ssh PASSTHROUGH_HOST "killall ssh" 2> /dev/null;
    killall ssh;
}

if [ $2 ]; then
    PORT=$2;
else
    PORT=20000;
fi

echo $0 $1 $2
case $1 in
    start) tunnel_start $PORT;;
    stop) tunnel_stop;;
    restart)
        tunnel_stop;
        tunnel_start;;
    *)
        echo "$0 (start|stop|restart) [port]"
esac
