#!/bin/bash

helm install $SPARK_CHART_NAME /opt/spark \
    --set serviceAccount.name=default \
    --set serviceAccount.create=false \
    --set master.podSecurityContext.runAsUser=$UID \
    --set master.containerSecurityContext.runAsUser=$UID \
    --set worker.podSecurityContext.runAsUser=$UID \
    --set worker.containerSecurityContext.runAsUser=$UID \
    --set master.podSecurityContext.runAsGroup=0 \
    --set master.podSecurityContext.fsGroup=0 \
    --set worker.podSecurityContext.runAsGroup=0 \
    --set worker.podSecurityContext.fsGroup=0 \
    --set worker.resources.limits.memory=20G \
    --set worker.resources.limits.memory=20G \
    --set worker.resources.limits.cpu=2 \
    --set worker.resources.requests.cpu=1 \
    --set master.resources.limits.cpu=1 \
    --set master.resources.requests.cpu=0.5 \
    --set master.resources.limits.memory=8G \
    --set master.resources.requests.memory=8G