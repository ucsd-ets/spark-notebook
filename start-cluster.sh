#!/bin/bash

IFS=: read -r FILESYSTEM HOMEMOUNT <<< $(findmnt -n -o SOURCE --target /home/$USER)

WORKSPACE=$(dirname $HOMEMOUNT)
WORKSPACE=$(dirname $WORKSPACE)

helm install $SPARK_CHART_NAME /opt/spark \
    --set image.registry=ghcr.io \
    --set image.repository=ucsd-ets/spark-node \
    --set image.tag=fa22-3 \
    --set image.pullPolicy=Always \
    --set serviceAccount.name=default \
    --set serviceAccount.create=false \
    --set master.podSecurityContext.runAsUser=$UID \
    --set master.containerSecurityContext.runAsUser=$UID \
    --set worker.replicaCount=3 \
    --set worker.podSecurityContext.runAsUser=$UID \
    --set worker.containerSecurityContext.runAsUser=$UID \
    --set master.podSecurityContext.runAsGroup=0 \
    --set master.podSecurityContext.fsGroup=0 \
    --set worker.podSecurityContext.runAsGroup=0 \
    --set worker.podSecurityContext.fsGroup=0 \
    --set worker.resources.limits.memory=20G \
    --set worker.coreLimit=2 \
    --set worker.resources.limits.cpu=2 \
    --set worker.resources.requests.cpu=2 \
    --set master.resources.limits.cpu=2 \
    --set master.resources.requests.cpu=2 \
    --set master.resources.limits.memory=8G \
    --set master.resources.requests.memory=8G \
    --set master.memoryLimit=8G \
    --set worker.memoryLimit=20G \
    --set-json="worker.extraVolumes[0]={\"name\":\"course-workspace\",\"nfs\":{\"server\":\"${FILESYSTEM}\",\"path\":\"${WORKSPACE}\"}}" \
    --set-json='worker.extraVolumes[1]={"name":"home","persistentVolumeClaim":{"claimName":"home"}}' \
    --set-json='worker.extraVolumeMounts[0]={"name":"course-workspace","mountPath":"/home/${USER}"}' \
    --set worker.extraVolumeMounts[0].mountPath=/home/$USER \
    --set worker.extraVolumeMounts[0].subPath=home/$USER \
    --set-json='worker.extraVolumeMounts[1]={"name":"course-workspace","mountPath":"/home/${USER}/public"}' \
    --set worker.extraVolumeMounts[1].mountPath=/home/$USER/public \
    --set worker.extraVolumeMounts[1].subPath=public \
    --set-json='worker.extraVolumeMounts[2]={"name":"home","mountPath":"/home/${USER}/private"}' \
    --set worker.extraVolumeMounts[2].mountPath=/home/$USER/private \
    --set-json="master.extraVolumes[0]={\"name\":\"course-workspace\",\"nfs\":{\"server\":\"${FILESYSTEM}\",\"path\":\"${WORKSPACE}\"}}" \
    --set-json='master.extraVolumes[1]={"name":"home","persistentVolumeClaim":{"claimName":"home"}}' \
    --set-json='master.extraVolumeMounts[0]={"name":"course-workspace","mountPath":"/home/${USER}"}' \
    --set master.extraVolumeMounts[0].mountPath=/home/$USER \
    --set master.extraVolumeMounts[0].subPath=home/$USER \
    --set-json='master.extraVolumeMounts[1]={"name":"course-workspace","mountPath":"/home/${USER}/public"}' \
    --set master.extraVolumeMounts[1].mountPath=/home/$USER/public \
    --set master.extraVolumeMounts[1].subPath=public \
    --set-json='master.extraVolumeMounts[2]={"name":"home","mountPath":"/home/${USER}/private"}' \
    --set master.extraVolumeMounts[2].mountPath=/home/$USER/private