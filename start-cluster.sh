#!/bin/bash

# install helm chart
helm install $SPARK_CHART_NAME $SPARK_CHART_PATH \
--set masterHostName=$(hostname) \
--set uid=$(id -u) \
--set username=$USER