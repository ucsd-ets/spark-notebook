#!/bin/bash

# automatically export env variables
#set -A
set -a

# Use this file to override default Spark cluster configuration set by '/opt/start-cluster.sh'
# e.g.

SPARK_CLUSTER_REPLICAS=3

# Permit individual per-user overrides
[ -f ~/.spark-cluster-configuration-profile.sh ] && . ~/.spark-cluster-configuration-profile.sh

echo spark-cluster-configuration-profile.sh >>  ~/startup.log
id >> ~/startup.log
# remove any user created with numeric uid
echo before  >> ~/startup.log
cat /tmp/passwd.wrap >> ~/startup.log
sed -i "/^${NB_UID}:/d" /tmp/passwd.wrap
cat /tmp/passwd.wrap >> ~/startup.log
echo after >> ~/startup.log
