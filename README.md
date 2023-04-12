# spark-notebook

## Development

Must be developed on dsmlp-login as it's coupled to that system

## Architecture

`start-cluster.sh` and `stop-cluster.sh` are meant to run as kubernetes lifecycle hooks to start and stop the cluster as the pod starts

## Cluster Configuration

The cluster and master/worker nodes may be configured via the following environment variables.

SPARK_CHART_NAME
: Helm chart used to instantiate Spark cluster
: Default =

SPARK_CLUSTER_IMAGE_REGISTRY
: Default = ghcr.io
SPARK_CLUSTER_IMAGE_REPO ucsd-ets/spark-node
: Default = ucsd-ets/spark-node
SPARK_CLUSTER_IMAGE_TAG
: Default = fa22-3

SPARK_CLUSTER_MASTER_CPU
: Number of CPU cores assigned to Master node (sets kubernetes request&limit)
: Default = 2
SPARK_CLUSTER_MASTER_MEM
: Memory assigned to Master node (sets kubernetes request&limit)
: Default = 8G

SPARK_CLUSTER_WORKER_CPU
: Number of CPU cores assigned to Worker nodes (sets kubernetes request&limit)
: Default = 2
SPARK_CLUSTER_WORKER_MEM
: Memory assigned to Worker node (sets kubernetes request&limit)
: Default = 20G
SPARK_CLUSTER_WORKER_APP_MEM
: Spark application memory limit (should be ~2GB less than WORKER_MEM)
: Default = 18G
SPARK_CLUSTER_REPLICAS
: Number of worker nodes to start up
: Default = 3

SPARK_CLUSTER_RUNASGROUP 
: Primary Unix group ID assigned to cluster nodes
: Default value: 0
SPARK_CLUSTER_FSGROUP 
: Supplemental Unix group ID assigned to cluster nodes
: Default value: 0

