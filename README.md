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
- ### Build pods
```bash
# clone this repo into its-dsmlpdev-master2:/home/<username>

sudo -s # login as root
chown -R <username> # change ownership so you can edit files
cd k8s-yamls
kubectl apply -f pods.yaml # to run yaml file to build pods

# TIPS
# check spark pods, should see 2 "Running"
kubectl get pods | grep spark 
# check spark service
kubectl describe svc <SERVICE_NAME>
# check detailed logs and error (if get one)
kubectl logs <POD_NAME>
# delete the environment if something is wrong at any time. then re-run yaml file.
kubectl delete -f pods.yaml
```
- ### Get master pod (spark-main) to work
**UPDATE: This section has been automated. Please confirm that command and args entries are in pods.yaml spark-main section. Skip this if there.**
```bash
# go into master pod
kubectl exec -it spark-main -- /bin/bash

find / -name <FILE_NAME> # TIP: to search entire filesystem for a file
# Start the node inside pod
./spark-3.3.0-bin-hadoop3/sbin/start-master.sh 
```
- ### port forward to localhost and confirm in web UI
```bash 
# For detailed instruction, please check: https://collab.ucsd.edu/display/ETS/Process+%28DRAFT%29%3A+SSH+Tunneling+to+Service+in+k8s+on+dsmlpdev

# if default 8080 doesn't work, try other port like 7070:8080, 
# then change to ssh -L 7070:localhost:7070 ......
kubectl port-forward <Master_POD_NAME> 8080:8080 # on its-dsmlpdev-master2
ssh -L 8080:localhost:8080 -N <username>@its-dsmlpdev-master2.ucsd.edu # on local terminal

# TIPS: 
# If you messed up the port-forward, kill them all to cleanup
lsof -i:8080 # list all process listening to a port, confirm they are safe to delete, then
pkill -f 'port-forward'


# open a tab and go to localhost:<PORT>, you should see the Spark page loading
```
- ### Get worker pod (spark-dev) to work
**UPDATE: This section has been automated. Please confirm that command and args entries are in pods.yaml spark-dev section. Skip this if there.**
```bash
# open a separate terminal and get into spark-dev
kubectl exec -it spark-dev -- /bin/bash

# Connect spark-dev to master node
# <URL> is the URL on the first line of the spark page you just opened (localhost:<PORT>)
# should be something like "spark://spark-main:<PORT>"
./spark-3.3.0-bin-hadoop3/sbin/start-worker.sh <URL>

# Now refresh the page, you should see an alive worker. 
```