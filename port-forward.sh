#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MASTER_POD="$(kubectl get pods -n wuykimpang 2>&1 | awk '/master/ {print $1}')"
stdbuf -o0 kubectl port-forward -n wuykimpang --address 127.0.0.1 $MASTER_POD 0:8888 0:8080 0:4040 > $BASEDIR/port_forwarding  2>/dev/null &
sleep 2
temp=$(cat $BASEDIR/port_forwarding | wc -l)

while [ $temp != 3 ]
do
    sync && sleep 2
    temp=$(cat $BASEDIR/port_forwarding | wc -l)
done

SPARK_MGR_PORT="$(cat $BASEDIR/port_forwarding | grep 8080 | grep 127.0.0.1 | awk '//{print $3}')"
SPARK_JOB_PORT="$(cat $BASEDIR/port_forwarding | grep 4040 | grep 127.0.0.1 | awk '//{print $3}')"

SSH_COMMAND="ssh -N -L 127.0.0.1:8080:$SPARK_MGR_PORT -L 127.0.0.1:4040:$SPARK_JOB_PORT wuykimpang@dsmlp-login.ucsd.edu"
echo $SSH_COMMAND