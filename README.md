# spark-notebook

## Development

### Build the container

`docker build -t ucsdets/spark-notebook:latest .`

### Enter into the container

```
# command to start the container
# container definition
# bind local port 8888 to container port 8888

docker run -p 8888:8888 -ti ucsdets/spark-notebook:latest /bin/bash
```

### Verify spark works

Checkout this guide https://sparkbyexamples.com/pyspark-tutorial/

`spark-shell` runs inside container  
OR  
`spark-shell & ` runs spark in the background

`:quit` returns to the container

### Start a jupyter notebook

`jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root` # you have to be inside the container  
Open the jupyter notebook following the url in the output.

### Verify pyspark works
Enter `python3` inside container to start an interactive python session and run the following:  
```python
from pyspark.sql import SparkSession    # import for session creation
spark = SparkSession.builder.getOrCreate()    # create the session
data = [("Java", "20000"), ("Python", "100000"), ("Scala", "3000")]
df = spark.createDataFrame(data)
df.show()
```

### k8s development

```bash
# clone this repo into its-dsmlpdev-master2:/home/<username>

sudo -s # login as root
cd k8s-yamls
kubectl apply -f pods.yaml

# to see if pods are running
kubectl get pods 
kubectl get pods | grep spark # to filter for spark pods

# to go into a pod
kubectl exec -it spark-master /bin/bash
kubectl exec -it spark-worker /bin/bash

# follow this guide to attempt to setup a spark cluster
# https://medium.com/codex/setup-a-spark-cluster-step-by-step-in-10-minutes-922c06f8e2b1
# skip this step SPARK_MASTER_HOST=192.168.0.1
# master scripts located at /opt/spark-3.3.0-bin-hadoop3/sbin/

find / -name "script_name.sh" # to search entire filesystem for a file

# once you get spark master and spark worker running together, port forward all the way to your localhost and confirm that they're connected in the web UI https://collab.ucsd.edu/display/ETS/Process+%28DRAFT%29%3A+SSH+Tunneling+to+Service+in+k8s+on+dsmlpdev

kubectl port-forward spark-master 8080:8080 # on its-dsmlpdev-master2
ssh -L 8080:localhost:8080 -N <username>@its-dsmlpdev-master2.ucsd.edu

## to delete the environment
kubectl delete -f pods.yaml
```