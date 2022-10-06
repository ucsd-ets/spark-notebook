#!/bin/bash
/opt/spark-3.3.0-bin-hadoop3/sbin/start-master.sh
# install helm chart
helm install spark-notebook-chart /opt/spark-notebook-chart --set uid=$(id -u)