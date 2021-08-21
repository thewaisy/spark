#!/bin/bash

#SPARK_VERSION=3.0.2
#HADOOP_VERSION=2.7
#SCALA_VERSION=2.12.4
#JUPYTERLAB_VERSION=2.1.5

DOCKER_USER=waisy
SPARK_VERSION=3.1.2
HADOOP_VERSION=3.2
SCALA_VERSION=2.12.4
JUPYTERLAB_VERSION=2.1.5

VERSION=v1
TAG_VERSION="${SPARK_VERSION}-${VERSION}"
BASE_IMAGE=$DOCKER_USER/spark-base:$TAG_VERSION

set -e

docker build \
    -f ./base/spark-base.Dockerfile \
    -t $BASE_IMAGE \
    --build-arg SCALA_VERSION=$SCALA_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    --build-arg HADOOP_VERSION=$HADOOP_VERSION \
     ./base

# master
docker build \
    -f ./master/spark-master.Dockerfile \
    -t $DOCKER_USER/spark-master:$TAG_VERSION \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./master

# worker
docker build \
    -f ./worker/spark-worker.Dockerfile \
    -t $DOCKER_USER/spark-worker:$TAG_VERSION \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./worker

# submit
docker build \
    -f ./submit/spark-submit.Dockerfile \
    -t $DOCKER_USER/spark-submit:$TAG_VERSION \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    ./submit

# jupyter notelab
docker build \
    -f ./jupyterlab/jupyterlab.Dockerfile \
    -t $DOCKER_USER/jupyterlab:$TAG_VERSION \
    --build-arg BASE_IMAGE=$BASE_IMAGE \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    --build-arg jupyterlab_version=$JUPYTERLAB_VERSION \
    ./jupyterlab