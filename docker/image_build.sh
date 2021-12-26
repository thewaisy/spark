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
PYTHON_VERSION=3.8.10
PYTHON_VER=$(awk -F. '{print $1"."$2}' <<< $PYTHON_VERSION)

VERSION=v2
TAG_VERSION="${SPARK_VERSION}-${VERSION}"
BASE_IMAGE=$DOCKER_USER/spark-base:$TAG_VERSION

set -e

docker build \
    -f ./base/spark-base.Dockerfile \
    -t $BASE_IMAGE \
    --build-arg SCALA_VERSION=$SCALA_VERSION \
    --build-arg SPARK_VERSION=$SPARK_VERSION \
    --build-arg HADOOP_VERSION=$HADOOP_VERSION \
    --build-arg PYTHON_VERSION=$PYTHON_VERSION \
    --build-arg PYTHON_VER=$PYTHON_VER \
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

# docker push
docker push $DOCKER_USER/spark-base:$TAG_VERSION
docker push $DOCKER_USER/spark-master:$TAG_VERSION
docker push $DOCKER_USER/spark-worker:$TAG_VERSION
docker push $DOCKER_USER/spark-submit:$TAG_VERSION
docker push $DOCKER_USER/jupyterlab:$TAG_VERSION