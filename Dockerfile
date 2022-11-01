FROM ucsdets/datahub-base-notebook:2022.3-stable

USER root

RUN apt-get update && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:deadsnakes/ppa -y
# RUN apt-get update
RUN apt-get install default-jre -y && \
    apt-get install default-jdk -y && \
    apt-get install -y curl openssh-client vim && \
    apt-get install unzip

# define spark & hadoop versions, helm chart name & path
# ENV HADOOP_VERSION=3.3.4
# ENV SPARK_VERSION=3.3.0
ENV HADOOP_VERSION 2.7.3
ENV SPARK_VERSION 2.4.4
ENV KUBECTL_VERSION=v1.25.0
ENV PATH=$PATH:/opt/spark/bin
ENV SPARK_CHART_NAME=spark-notebook-chart
ENV SPARK_CHART_PATH=/opt/$SPARK_CHART_NAME

ENV PATH $PATH:/opt/spark/bin

# download and install hadoop
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | \
        tar -zx hadoop-${HADOOP_VERSION}/lib/native && \
    ln -s hadoop-${HADOOP_VERSION} hadoop && \
    echo Hadoop ${HADOOP_VERSION} native libraries installed in /opt/hadoop/lib/native

# download and install spark
RUN mkdir -p /opt && \
    cd /opt && \
    curl http://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz | \
        tar -zx && \
    ln -s spark-${SPARK_VERSION}-bin-hadoop2.7 spark && \:
    echo Spark ${SPARK_VERSION} installed in /opt

# download and install kubectl
WORKDIR /opt 
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    echo kubectl ${KUBECTL_VERSION} installed in /opt

# download and install helm
WORKDIR /opt 
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh

# add scripts and update spark default config
ADD spark-master spark-worker /
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf
# ADD spark-env.sh /opt/spark/conf/spark-env.sh
ADD jupyter_config.py /etc/jupyter/jupyter_config.py
ADD spark-notebook-chart/ /opt/spark-notebook-chart
ADD start-cluster.sh /opt/start-cluster.sh
ADD stop-cluster.sh /opt/stop-cluster.sh

ENV STOP_CLUSTER_SCRIPT_PATH=/opt/stop-cluster.sh

ADD PA2.zip /opt/PA2.zip
RUN unzip PA2.zip && \
    rm PA2.zip
ADD sanity_check.ipynb /opt/sanity_check.ipynb 

RUN chmod 777 /spark-master /spark-worker  /opt/*.sh \
    /opt/spark/conf/spark-defaults.conf /opt/spark-notebook-chart \
    /opt/sanity_check.ipynb && \
    mkdir /opt/spark/work && \
    chmod -R 777 /opt /opt/spark/work

# install pyspark
# https://spark.apache.org/docs/latest/api/python/getting_started/install.html
RUN PYSPARK_HADOOP_VERSION=3 pip install pyspark==2.4.4 -v

# install jupyter-server-proxy
RUN pip install jupyter-server-proxy databricks koalas -v
  
# install tensorflow and torch
RUN mamba install cudatoolkit=11.2 cudnn && \
    pip install tensorflow==2.6

ARG TORCH_VER="1.7.1+cu101"        
ARG TORCH_VIS_VER="0.8.2+cu101"        
ARG TORCH_AUD_VER="0.7.2"        
        
RUN pip install torch==${TORCH_VER} torchvision==${TORCH_VIS_VER} torchaudio==${TORCH_AUD_VER} \  
    -f https://download.pytorch.org/whl/torch_stable.html && \        
    fix-permissions $CONDA_DIR && \        
    fix-permissions /home/$NB_USER
