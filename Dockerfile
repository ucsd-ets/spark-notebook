FROM ucsdets/datahub-base-notebook:2022.3-stable

USER root

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt-get update
RUN apt-get install default-jre -y
RUN apt-get install default-jdk -y
RUN apt-get install -y curl openssh-client vim

# define spark and hadoop versions
ENV HADOOP_VERSION 3.3.4
ENV SPARK_VERSION 3.3.0
ENV PATH $PATH:/opt/spark/bin

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
RUN ln -s spark-${SPARK_VERSION}-bin-hadoop3.3 spark && \
    echo Spark ${SPARK_VERSION} installed in /opt

# add scripts and update spark default config
ADD common.sh spark-master spark-worker /
ADD spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# install pyspark
# https://spark.apache.org/docs/latest/api/python/getting_started/install.html
RUN PYSPARK_HADOOP_VERSION=3 pip install pyspark -v