
FROM docker.io/bitnami/spark:3.3.1-debian-11-r1

USER root

RUN apt-get update && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:deadsnakes/ppa -y
# RUN apt-get update
RUN apt-get install -y curl openssh-client vim && \
    apt-get install unzip

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
    chmod -R 777 /opt/PA2

# install pyspark
# https://spark.apache.org/docs/latest/api/python/getting_started/install.html
RUN pip install notebook pyspark -v

# install jupyter-server-proxy
RUN pip install jupyter-server-proxy databricks koalas -v

COPY start-notebook.sh /usr/local/bin
COPY start.sh /usr/local/bin
COPY start-singleuser.sh /usr/local/bin

RUN chmod 777 /usr/local/bin/start-notebook.sh /usr/local/bin/start.sh /usr/local/bin/start-singleuser.sh
  
# install tensorflow and torch
# RUN mamba install cudatoolkit=11.2 cudnn && \
#     pip install tensorflow==2.6

# ARG TORCH_VER="1.7.1+cu101"        
# ARG TORCH_VIS_VER="0.8.2+cu101"        
# ARG TORCH_AUD_VER="0.7.2"        
        
# RUN pip install torch==${TORCH_VER} torchvision==${TORCH_VIS_VER} torchaudio==${TORCH_AUD_VER} \  
#     -f https://download.pytorch.org/whl/torch_stable.html && \        
#     fix-permissions $CONDA_DIR && \        
#     fix-permissions /home/$NB_USER