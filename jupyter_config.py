c.ServerProxy.servers = {
  'test-server': {
    'command': ['/opt/spark-3.3.0-bin-hadoop3/bin/spark-class org.apache.spark.deploy.master.Master --host spark-jupyter --port 7077 --webui-port 8080 && /opt/start-workers.sh'],
    'absolute_url': False,
    'port': 8080
    }
}