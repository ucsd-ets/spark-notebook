FROM ucsdets/datahub-base-notebook:2022.3-stable

USER root

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update
RUN apt-get install default-jre -y
RUN apt-get install default-jdk -y
RUN apt-get install -y curl openssh-client vim
RUN apt-get install unzip

# define spark and hadoop versions
ENV HADOOP_VERSION=3.3.4
ENV SPARK_VERSION=3.3.0
ENV KUBECTL_VERSION=v1.25.0
ENV PATH=$PATH:/opt/spark/bin

# If the <docker build> throws errors on RUN curl command, it's most likely
#         the Hadoop and Spark version are out-dated or incompatible.
# Check https://spark.apache.org/downloads.html for latest version and compatibility.
# Note the 'bin-hadoop3' at the end of RUN curl of spark. This should be changed manually.

# download and install hadoop
WORKDIR /opt 
RUN curl http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | \
        tar -zx hadoop-${HADOOP_VERSION}/lib/native 
RUN ln -s hadoop-${HADOOP_VERSION} hadoop && \
    echo Hadoop ${HADOOP_VERSION} native libraries installed in /opt/hadoop/lib/native

# download and install spark
WORKDIR /opt 
RUN curl http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz | \
        tar -zx
RUN ln -s spark-${SPARK_VERSION}-bin-hadoop3 spark && \
    echo Spark ${SPARK_VERSION} installed in /opt

# download and install kubectl
WORKDIR /opt 
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
RUN echo kubectl ${KUBECTL_VERSION} installed in /opt

# download and install helm
WORKDIR /opt 
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN rm get_helm.sh

# add scripts and update spark default config
ADD common.sh spark-master spark-worker /
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
# ADD spark-env.sh /opt/spark/conf/spark-env.sh
ADD jupyter_config.py /etc/jupyter/jupyter_config.py
ADD spark-notebook-chart/ /opt/spark-notebook-chart
ADD start-cluster.sh /opt/start-cluster.sh
ADD PA2.zip /opt/PA2.zip
RUN unzip PA2.zip
RUN rm PA2.zip

RUN chmod 777 /spark-master /spark-worker  /opt/start-cluster.sh \
    /opt/spark/conf/spark-defaults.conf /opt/spark-notebook-chart
RUN chmod -R 777 /opt/PA2

# install pyspark
# https://spark.apache.org/docs/latest/api/python/getting_started/install.html
RUN PYSPARK_HADOOP_VERSION=3 pip install pyspark -v

# install jupyter-server-proxy
RUN pip install jupyter-server-proxy -v
RUN pip install databricks -v
RUN pip install koalas -v
