# spark-notebook

## Container and Image Development

- ### Build the container

`docker build -t ucsdets/spark-notebook:latest .`

- ### Enter into the container

```
# command to start the container
# container definition
# bind local port 8888 to container port 8888

docker run -p 8888:8888 -ti ucsdets/spark-notebook:latest /bin/bash
```

- ### Verify spark works

Checkout this guide https://sparkbyexamples.com/pyspark-tutorial/

`spark-shell` runs inside container  
OR  
`spark-shell & ` runs spark in the background

`:quit` returns to the container

- ### Start a jupyter notebook

`jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root` # you have to be inside the container  
Open the jupyter notebook following the url in the output.

- ### Verify pyspark works
Enter `python3` inside container to start an interactive python session and run the following:  
```python
from pyspark.sql import SparkSession    # import for session creation
spark = SparkSession.builder.getOrCreate()    # create the session
data = [("Java", "20000"), ("Python", "100000"), ("Scala", "3000")]
df = spark.createDataFrame(data)
df.show()
```

## k8s development: Set up a Spark Cluster
*We want to set up a Spark Cluster with 1 master pod, 3 worker pods(1 for jupyter)*
- ### Build pods
```bash
# clone this repo into its-dsmlpdev-master2:/home/<username>

sudo -s # login as root
chown -R <username> . # change ownership so you can edit files
kubectl apply -f k8s-yamls/master.yaml # to run yaml file to build master pod

# TIPS
# check pod status, should see 1 "Running" (spark-jupyter)
kubectl get pods | grep spark 
kubectl describe pod <POD_NAME>
# check spark service (not needed now, services are created in helm chart)
kubectl get svc | grep spark 
kubectl describe svc <SERVICE_NAME>
# check logs and error (if get one); you can exec into the pod (see below section) for a detailed log
kubectl logs <POD_NAME>
# delete the environment if something is wrong at any time. then re-run yaml file.
kubectl delete -f k8s-yamls/master.yaml
helm uninstall spark-notebook-chart # workers and service will be handled by helm
```
- ### Get master pod (spark-jupyter) to work
**UPDATE: This section has been automated.**
```bash
# go into jupyter pod
kubectl exec -it spark-jupyter -- /bin/bash

find / -name <FILE_NAME> # TIP: to search entire filesystem for a file
# Start the node inside pod
./spark-3.3.0-bin-hadoop3/sbin/start-master.sh 
```
- ### port forward to localhost and confirm in web UI
```bash 
# For detailed instruction, please check: https://collab.ucsd.edu/display/ETS/Process+%28DRAFT%29%3A+SSH+Tunneling+to+Service+in+k8s+on+dsmlpdev

# Current setting: 8081 for workers, 8082 for jupyter pod (role of master)
# if default ones don't work, try other ports
# on its-dsmlpdev-master2
kubectl port-forward spark-jupyter 8082:8888 # jupyter pod
# on local terminal
ssh -L 8082:localhost:8082 -N haw085@its-dsmlpdev-master2.ucsd.edu # jupyter pod

# Then you should be able to open a jupyter notebook at:
localhost:8082

# TIPS: 
# If you messed up the port-forward, kill them all to cleanup
lsof -i:8082 # list all process listening to a port, confirm they are safe to delete, then
pkill -f 'port-forward'
```
- ### Get worker pod (spark-dev) to work
**UPDATE 1: This section has been automated.**
```bash
# open a separate terminal and get into spark-dev
kubectl exec -it <WORKER_POD_NAME> -- /bin/bash

# Connect spark-dev to master node
# <URL> is the URL on the first line of the spark page you just opened (localhost:<PORT>)
# should be something like "spark://spark-main:<PORT>"
./spark-3.3.0-bin-hadoop3/sbin/start-worker.sh <URL>
```
**UPDATE 2: We change the workflow by moving the creation of 2 worker pods and all services inside helm chart. Once the user open a test-server, helm chart will be created, with all services and 2 worker pods**

By clicking New -> test-server, you should see a spark dashboard; 
wait for 1 min and refresh, you should see 2 workers connected.

- ### Test PySpark works
**Please make sure that this piece of code works.**
```python
# You can either exec into a pod and run "python3" to start an interactive python session
# or use a test notebook script.
# We recommend do BOTH.
from pyspark.sql import SparkSession
spark = SparkSession.builder.master("spark://spark-main:7077").getOrCreate()
print("spark session created")

```

- ### General TIPS:
- If you make any change to pods.yaml, it's recommended to kubectl delete -f pods.yaml then kubectl apply -f pods.yaml
- If you make changes to Dockerfile, you must push the change to Github, wait for the action build to complete, before running kubectl apply -f pods.yaml.