#!/bin/bash
helm uninstall spark-notebook-chart
kubectl delete -f k8s-yamls/master.yaml