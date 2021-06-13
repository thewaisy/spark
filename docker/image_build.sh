#!/bin/bash


#SPARK_VERSION=3.0.2
#HADOOP_VERSION=2.7
#SCALA_VERSION=2.12.4
#JUPYTERLAB_VERSION=2.1.5


SPARK_VERSION=2.4.8
HADOOP_VERSION=2.7
SCALA_VERSION=2.12.4
JUPYTERLAB_VERSION=2.1.5


set -e

docker build \
    -f ./base/spark-base.Dockerfile \
    -t hanyoon1108/spark-base:"${SPARK_VERSION}" \
    --build-arg SCALA_VERSION=$SCALA_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    --build-arg HADOOP_VERSION=$HADOOP_VERSION \
     ./base

docker build \
    -f ./master/spark-master.Dockerfile \
    -t hanyoon1108/spark-master:"$SPARK_VERSION" \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./master

docker build \
    -f ./worker/spark-worker.Dockerfile \
    -t hanyoon1108/spark-worker:"${SPARK_VERSION}" \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./worker

docker build \
    -f ./submit/spark-submit.Dockerfile \
    -t hanyoon1108/spark-submit:"${SPARK_VERSION}" \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./submit

docker build \
    -f ./jupyterlab/jupyterlab.Dockerfile \
    -t hanyoon1108/jupyterlab:"${SPARK_VERSION}" \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    --build-arg jupyterlab_version=$JUPYTERLAB_VERSION \
    ./jupyterlab