FROM openjdk:8-jre-slim

LABEL author="hanyoon" email="mit2011@naver.com"
LABEL version="v4"

ENV DAEMON_RUN=true
ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG SCALA_VERSION
#ENV SPARK_VERSION=3.0.2
#ENV HADOOP_VERSION=2.7
#ENV SCALA_VERSION=2.12.4
ENV SCALA_HOME=/usr/share/scala
ENV SPARK_HOME=/spark
ENV SPARK_CONF_DIR=$SPARK_HOME/conf
ENV YARN_CONF_DIR=$SPARK_CONF_DIR

COPY ./requirements.txt /requirements.txt

RUN apt-get update && apt-get install -y curl vim wget software-properties-common ssh net-tools ca-certificates jq

# scala install
RUN cd "/tmp" && \
    wget --no-verbose "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "/tmp/"*

# install python 3.8
# Add Dependencies for PySpark
RUN apt-get install -y build-essential checkinstall && \
    apt-get install -y libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    liblzma-dev

RUN wget https://www.python.org/ftp/python/3.8.12/Python-3.8.12.tar.xz -O /opt/Python-3.8.12.tar.xz && \
    tar -xvf /opt/Python-3.8.12.tar.xz -C /opt && \
    cd /opt/Python-3.8.12 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    update-alternatives --install /usr/bin/python python /usr/local/bin/python3.8 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.8 1 && \
    cd /


# RUN apt-get install -y python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy
# RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

RUN pip install --upgrade pip && \
    pip install -r requirements.txt

#Scala instalation
RUN export PATH="/usr/local/sbt/bin:$PATH" && \
    apt update && apt install ca-certificates wget tar && \
    mkdir -p "/usr/local/sbt" && \
    wget -qO - --no-check-certificate "https://github.com/sbt/sbt/releases/download/v1.2.8/sbt-1.2.8.tgz" | tar xz -C /usr/local/sbt --strip-components=1 && \
    sbt sbtVersion


# spark install
RUN wget --no-verbose http://apache.mirror.cdnetworks.com/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xvzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# add jar
# mysql
# presto
# aws-java-sdk-bundle
# hadoop-aws
# hive-metastore
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar \
        -O ${SPARK_HOME}/jars/mysql-connector-java-5.1.47.jar && \
    wget https://repo1.maven.org/maven2/com/facebook/presto/presto-jdbc/0.257/presto-jdbc-0.257.jar \
        -O ${SPARK_HOME}/jars/presto-jdbc-0.257.jar && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.167/aws-java-sdk-bundle-1.12.167.jar \
        -O ${SPARK_HOME}/jars/aws-java-sdk-bundle-1.12.167.jar && \
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.2.2/hadoop-aws-3.2.2.jar \
        -O ${SPARK_HOME}/jars/hadoop-aws-3.2.2.jar && \
    wget https://repo1.maven.org/maven2/org/apache/hive/hive-metastore/3.0.0/hive-metastore-3.0.0.jar \
        -O ${SPARK_HOME}/jars/hive-metastore-3.0.0.jar

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV PYTHONHASHSEED 1