FROM docker.io/bitnami/spark:3.3.1-debian-11-r1

USER root

RUN chmod -R 777 /opt/bitnami/spark/tmp /opt/bitnami/spark/conf

USER 1001

RUN pip install databricks==0.2 koalas==1.8.2
