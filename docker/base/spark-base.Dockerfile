FROM openjdk:8-jre-slim

LABEL author="hanyoon" email="mit2011@naver.com"
LABEL version="v2"

ENV DAEMON_RUN=true
ARG SPARK_VERSION
ARG HADOOP_VERSION
ARG SCALA_VERSION
ARG PYTHON_VERSION
ARG PYTHON_VER
#ENV SPARK_VERSION=3.0.2
#ENV HADOOP_VERSION=2.7
#ENV SCALA_VERSION=2.12.4
ENV SPARK_MASTER_HOST='spark-master'
ENV SCALA_HOME='/usr/share/scala'
ENV SPARK_HOME='/spark'
ENV SPARK_CONF_DIR='${SPARK_HOME}/conf'
ENV YARN_CONF_DIR=$SPARK_CONF_DIR


RUN apt-get update && apt-get install -y build-essential curl vim wget ssh net-tools ca-certificates jq
# apt-get install software-properties-common -> python3.9 꼬임

# scala install
RUN cd "/tmp" && \
    wget --no-verbose "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "/tmp/"*

# install python
# Add Dependencies for PySpark
RUN apt-get install -y zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev \
    libsqlite3-dev libreadline-dev libffi-dev libbz2-dev liblzma-dev libfreetype6-dev pkg-config

RUN wget "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz" -P /opt && \
    tar -xvf /opt/Python-$PYTHON_VERSION.tar.xz -C /opt && \
    cd /opt/Python-$PYTHON_VERSION && \
    ./configure --enable-optimizations && \
    make altinstall && \
    update-alternatives --install /usr/bin/python python /usr/local/bin/python$PYTHON_VER 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python$PYTHON_VER 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip$PYTHON_VER 1 && \
    update-alternatives --install /usr/bin/pip3 pip3 /usr/local/bin/pip$PYTHON_VER 1 && \
    cd /


COPY ./requirements.txt /requirements.txt
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

# add mysql jar
RUN wget https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.47/mysql-connector-java-5.1.47.jar -O ${SPARK_HOME}/jars/mysql-connector-java-5.1.47.jar

# add presto jar
RUN wget https://repo1.maven.org/maven2/com/facebook/presto/presto-jdbc/0.266.1/presto-jdbc-0.266.1.jar -O ${SPARK_HOME}/jars/presto-jdbc-0.257.jar


# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV PYTHONHASHSEED 1