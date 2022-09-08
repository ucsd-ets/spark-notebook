c.ServerProxy.servers = {
  'test-server': {
    'command': [
        '/opt/spark-3.3.0-bin-hadoop3/sbin/start-master.sh',
        '/opt/start-workers.sh'],
    'absolute_url': False,
    'port': 8080
    }
}