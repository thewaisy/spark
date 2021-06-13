ARG SPARK_VERSION
FROM hanyoon1108/spark-base:${SPARK_VERSION}

# -- Layer: JupyterLab
ARG SPARK_VERSION
ARG jupyterlab_version=2.1.5
ARG jupyter=8888

RUN apt-get update -y && \
    apt-get install -y python3-pip && \
    pip3 install wget pyspark==${SPARK_VERSION} jupyterlab==${jupyterlab_version} numpy
# -- Runtime

EXPOSE ${jupyter}
WORKDIR /opt/spark-data/jupyter
CMD jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=
