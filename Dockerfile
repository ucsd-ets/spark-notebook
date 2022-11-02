
FROM docker.io/bitnami/spark:3.3.1-debian-11-r1

USER root

RUN apt-get update && \
    apt-get install curl openssh-client vim unzip wget -y

# download and install kubectl
ENV KUBECTL_VERSION=v1.25.0
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
# ADD spark-env.sh /opt/spark/conf/spark-env.sh
ADD jupyter_config.py /etc/jupyter/jupyter_config.py
ADD start-cluster.sh /opt/start-cluster.sh
ADD stop-cluster.sh /opt/stop-cluster.sh
ADD port-forward.sh /opt/port-forward.sh
ADD sanity_check.ipynb /opt/sanity_check.ipynb

RUN chmod 777  /opt/*.sh /opt/*.ipynb

ENV SPARK_CHART_NAME=spark
ENV STOP_CLUSTER_SCRIPT_PATH=/opt/stop-cluster.sh
ENV START_CLUSTER_SCRIPT_PATH=/opt/start-cluster.sh

ENV SHELL=/bin/bash

# install pyspark
# https://spark.apache.org/docs/latest/api/python/getting_started/install.html
RUN pip3 install notebook==6.4.0 pyspark jupyter-server-proxy jupyterhub==1.5.0 databricks koalas pandas -v

# jupyter compatibility
COPY start-notebook.sh /usr/local/bin
COPY start.sh /usr/local/bin
COPY start-singleuser.sh /usr/local/bin

RUN chmod 777 /usr/local/bin/start-notebook.sh /usr/local/bin/start.sh /usr/local/bin/start-singleuser.sh

RUN helm repo add bitnami https://charts.bitnami.com/bitnami && \
    helm repo update && \
    helm pull bitnami/spark --version=6.3.9 && \
    tar -zxf spark*.tgz && \
    chmod -R 777 /opt/spark

USER 1000

ENV PATH=/opt/bitnami/python/bin:/opt/bitnami/java/bin:/opt/bitnami/spark/bin:/opt/bitnami/spark/sbin:/opt/bitnami/common/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/miniconda.sh && \
#     bash /opt/miniconda.sh -b -p /opt/miniconda

# ENV PATH=/opt/miniconda/bin:$PATH

# install tensorflow and torch
# RUN conda install -c anaconda cudatoolkit=11.2 cudnn -y && \
#     pip install tensorflow==2.6

# ARG TORCH_VER="1.7.1+cu101"        
# ARG TORCH_VIS_VER="0.8.2+cu101"        
# ARG TORCH_AUD_VER="0.7.2"        
        
# RUN pip install torch==${TORCH_VER} torchvision==${TORCH_VIS_VER} torchaudio==${TORCH_AUD_VER} \  
#     -f https://download.pytorch.org/whl/torch_stable.html && \        
#     fix-permissions $CONDA_DIR && \        
#     fix-permissions /home/$NB_USER