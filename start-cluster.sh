#!/bin/bash

IFS=: read -r FILESYSTEM HOMEMOUNT <<< $(findmnt -n -o SOURCE --target /home/$USER)

WORKSPACE=$(dirname $HOMEMOUNT)
WORKSPACE=$(dirname $WORKSPACE)

helm install $SPARK_CHART_NAME /opt/spark \
    --set image.registry=${SPARK_CLUSTER_IMAGE_REGISTRY:-ghcr.io} \
    --set image.repository=${SPARK_CLUSTER_IMAGE_REPO:-ucsd-ets/spark-node} \
    --set image.tag=${SPARK_CLUSTER_IMAGE_TAG:-fa22-3} \
    --set image.pullPolicy=Always \
    --set serviceAccount.name=default \
    --set serviceAccount.create=false \
    --set master.podSecurityContext.runAsUser=$UID \
    --set master.containerSecurityContext.runAsUser=$UID \
    --set worker.replicaCount=${SPARK_CLUSTER_REPLICAS:-3} \
    --set worker.podSecurityContext.runAsUser=$UID \
    --set worker.containerSecurityContext.runAsUser=$UID \
    --set master.podSecurityContext.runAsGroup=${SPARK_CLUSTER_RUNASGROUP:-0} \
    --set master.podSecurityContext.fsGroup=${SPARK_CLUSTER_FSGROUP:-0} \
    --set worker.podSecurityContext.runAsGroup=${SPARK_CLUSTER_RUNASGROUP:-0} \
    --set worker.podSecurityContext.fsGroup=${SPARK_CLUSTER_FSGROUP:-0} \
    --set worker.resources.requests.memory=${SPARK_CLUSTER_WORKER_MEM:-20G} \
    --set worker.resources.limits.memory=${SPARK_CLUSTER_WORKER_MEM:-20G} \
    --set worker.coreLimit=${SPARK_CLUSTER_WORKER_CPU:-2} \
    --set worker.resources.limits.cpu=${SPARK_CLUSTER_WORKER_CPU:-2} \
    --set worker.resources.requests.cpu=${SPARK_CLUSTER_WORKER_CPU:-2} \
    --set master.resources.limits.cpu=${SPARK_CLUSTER_MASTER_CPU:-2} \
    --set master.resources.requests.cpu=${SPARK_CLUSTER_MASTER_CPU:-2} \
    --set master.resources.limits.memory=${SPARK_CLUSTER_MASTER_MEM:-8G} \
    --set master.resources.requests.memory=${SPARK_CLUSTER_MASTER_MEM:-8G} \
    --set master.memoryLimit=${SPARK_CLUSTER_MASTER_MEM:-8G} \
    --set worker.memoryLimit=${SPARK_CLUSTER_WORKER_APP_MEM:-18G} \
    --set-json="worker.extraVolumes[0]={\"name\":\"course-workspace\",\"nfs\":{\"server\":\"${FILESYSTEM}\",\"path\":\"${WORKSPACE}\"}}" \
    --set-json='worker.extraVolumes[1]={"name":"home","persistentVolumeClaim":{"claimName":"home"}}' \
    --set-json="worker.extraVolumes[2]={\"name\":\"datasets\",\"nfs\":{\"server\":\"its-dsmlp-fs04.ucsd.edu\",\"path\":\"/export/workspaces/DSC102_SP25_A00/public/dataset_public\"}}" \
    --set-json="worker.extraVolumes[3]={\"name\":\"private-datasets\",\"nfs\":{\"server\":\"its-dsmlp-fs04.ucsd.edu\",\"path\":\"/export/workspaces/DSC102_SP25_A00/private-dataset/dsc102-private-dataset\"}}" \
    --set-json='worker.extraVolumeMounts[0]={"name":"course-workspace","mountPath":"/home/${USER}"}' \
    --set worker.extraVolumeMounts[0].mountPath=/home/$USER \
    --set worker.extraVolumeMounts[0].subPath=home/$USER \
    --set-json='worker.extraVolumeMounts[1]={"name":"course-workspace","mountPath":"/home/${USER}/public"}' \
    --set worker.extraVolumeMounts[1].mountPath=/home/$USER/public \
    --set worker.extraVolumeMounts[1].subPath=public \
    --set-json='worker.extraVolumeMounts[2]={"name":"home","mountPath":"/home/${USER}/private"}' \
    --set worker.extraVolumeMounts[2].mountPath=/home/$USER/private \
    --set-json='worker.extraVolumeMounts[3]={"name":"datasets","mountPath":"/datasets/courses/dsc102/public"}' \
    --set-json='worker.extraVolumeMounts[4]={"name":"private-datasets","mountPath":"/datasets/courses/dsc102/private"}' \
    --set-json="master.extraVolumes[0]={\"name\":\"course-workspace\",\"nfs\":{\"server\":\"${FILESYSTEM}\",\"path\":\"${WORKSPACE}\"}}" \
    --set-json='master.extraVolumes[1]={"name":"home","persistentVolumeClaim":{"claimName":"home"}}' \
    --set-json="master.extraVolumes[2]={\"name\":\"datasets\",\"nfs\":{\"server\":\"its-dsmlp-fs04.ucsd.edu\",\"path\":\"/export/workspaces/DSC102_SP25_A00/public/dataset_public\"}}" \
    --set-json="master.extraVolumes[3]={\"name\":\"private-datasets\",\"nfs\":{\"server\":\"its-dsmlp-fs04.ucsd.edu\",\"path\":\"/export/workspaces/DSC102_SP25_A00/private-dataset/dsc102-private-dataset\"}}" \
    --set-json='master.extraVolumeMounts[0]={"name":"course-workspace","mountPath":"/home/${USER}"}' \
    --set master.extraVolumeMounts[0].mountPath=/home/$USER \
    --set master.extraVolumeMounts[0].subPath=home/$USER \
    --set-json='master.extraVolumeMounts[1]={"name":"course-workspace","mountPath":"/home/${USER}/public"}' \
    --set master.extraVolumeMounts[1].mountPath=/home/$USER/public \
    --set master.extraVolumeMounts[1].subPath=public \
    --set-json='master.extraVolumeMounts[2]={"name":"home","mountPath":"/home/${USER}/private"}' \
    --set-json='master.extraVolumeMounts[3]={"name":"datasets","mountPath":"/datasets/courses/dsc102/public"}' \
    --set-json='master.extraVolumeMounts[4]={"name":"private-datasets","mountPath":"/datasets/courses/dsc102/private"}' \
    --set master.extraVolumeMounts[2].mountPath=/home/$USER/private

ln -s /home/$USER/public/dataset_public /datasets/courses/dsc102/public
