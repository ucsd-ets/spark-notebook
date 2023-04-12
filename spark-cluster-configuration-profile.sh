#!/bin/bash

# automatically export env variables
set -A

# Use this file to override default Spark cluster configuration set by '/opt/start-cluster.sh'
# e.g.

SPARK_CLUSTER_REPLICAS=3

# Permit individual per-user overrides
[ -f ~/.spark-cluster-configuration-profile.sh ] && . ~/.spark-cluster-configuration-profile.sh

