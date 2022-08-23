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

`spark-shell` runs inside container, run it in the background
`spark-shell &` runs spark in the background

### Start a jupyter notebook

`jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root # you have to be inside the container`

### Verify pyspark works


```python
import pyspark as spark
data = [("Java", "20000"), ("Python", "100000"), ("Scala", "3000")]
df = spark.createDataFrame(data)
df.show()
```