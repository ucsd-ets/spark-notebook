#!/bin/bash

# automatically export env variables
#set -A
set -a

# Use this file to override default Spark cluster configuration set by '/opt/start-cluster.sh'
# e.g.

SPARK_CLUSTER_REPLICAS=3

# Permit individual per-user overrides
[ -f ~/.spark-cluster-configuration-profile.sh ] && . ~/.spark-cluster-configuration-profile.sh

MYUID=`id -u`
# echo --- >> ~/startup.log
# echo spark-cluster-configuration-profile.sh >>  ~/startup.log
# env >> ~/startup.log
# echo my uid is $MYUID
# id >> ~/startup.log
# # remove any user created with numeric uid
# echo before  >> ~/startup.log
# cat /tmp/passwd.wrap >> ~/startup.log
sed -i "/^${MYUID}:/d" /tmp/passwd.wrap
# echo after >> ~/startup.log
# cat /tmp/passwd.wrap >> ~/startup.log
