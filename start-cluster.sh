#!/bin/bash
/opt/spark-3.3.0-bin-hadoop3/sbin/start-master.sh
# install helm chart
helm install $SPARK_CHART_NAME $SPARK_CHART_PATH \
--set masterHostName=$(hostname) \
--set uid=$(id -u) \
--set username=$USER