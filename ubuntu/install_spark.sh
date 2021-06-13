#!/bin/bash


base(){
  #apt-get update -y && apt-get upgrade -y
  #
  #apt-get install -y sudo
  #
  apt-get install -y openjdk-8-jdk \
    wget \
    ssh \
    openssh-server

  export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
  export CLASSPATH=$JAVA_HOME/lib/tools.jar
  export PATH=$PATH:$JAVA_HOME/bin
  export PDSH_RCMD_TYPE=ssh
}

# install hadoop
hadoop_install(){
  cd /opt
  mkdir hadoop
  wget http://mirror.navercorp.com/apache/hadoop/common/hadoop-3.2.2/hadoop-3.2.2.tar.gz -O hadoop.tar.gz
  tar -xvzf hadoop.tar.gz --strip 1 -C hadoop
  rm hadoop.tar.gz

  mkdir -p /apps/hadoop/hdfs/namenode # (데이터를 저장하는 master)
  mkdir -p /apps/hadoop/hdfs/datanode # (데이터를 저장하는 slave)
  mkdir -p /apps/hadoop/hdfs/pids # (임시로 데이터를 저장하는 경로)

  #  /etc/enviroment
  export HADOOP_HOME=/opt/hadoop
  export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
  export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

  export HADOOP_MAPRED_HOME=${HADOOP_HOME}
  export HADOOP_COMMON_HOME=${HADOOP_HOME}
  export HADOOP_HDFS_HOME=${HADOOP_HOME}
  export YARN_HOME=${HADOOP_HOME}

  # hadoop-env.sh
  sed -i -e "s|# export JAVA_HOME=|export JAVA_HOME=$JAVA_HOME|g" $HADOOP_CONF_DIR/hadoop-env.sh
}

ssh-keygen -t rsa -P '' -f .ssh/id_rsa
cat .ssh/id_rsa.pub >> .ssh/authorized_keys

hdfs namenode -format

hadoop_standalone(){
  # core-site.xml
  sed -i -e 's/\<configuration\>.*\<\/configuration\>/asdasd/gm' $HADOOP_CONF_DIR/core-site.xml

  #  hdfs-site.yml
}

# install spark
spark_install(){
  export PYTHONHASHSEED=1

  cd /opt
  mkdir spark
  wget http://mirror.navercorp.com/apache/spark/spark-3.1.1/spark-3.1.1-bin-hadoop3.2.tgz
  tar -xvzf spark-3.1.1-bin-hadoop3.2.tgz -C spark

  export PYSPARK_PYTHON=/usr/bin/python
  export PYSPARK_DRIVER_PYTHON=/usr/bin/python

  export SPARK_HOME=/opt/spark/spark-3.1.1-bin-hadoop3.2
  export PATH=$PATH:$SPARK_HOME/bin
}

#scala_install(){
#  wget --no-verbose "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
#  tar xzf "scala-${SCALA_VERSION}.tgz" && \
#  mkdir "${SCALA_HOME}" && \
#  rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
#  mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
#  ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
#  rm -rf "/tmp/"*
#}

python_install() {
  TZ=Asia/Seoul

  #라이브러리 설치
  apt-get install -y build-essential checkinstall
  apt-get install -y libreadline-gplv2-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    liblzma-dev

  cd /opt
  sudo wget https://www.python.org/ftp/python/3.8.9/Python-3.8.9.tar.xz
  sudo tar -xvf Python-3.8.9.tar.xz
  rm Python-3.8.9.tar.xz

  cd Python-3.8.9
  sudo ./configure --enable-optimizations
  sudo make altinstall

  # 파이썬 3.8을 python커맨드의 디폴트로 설정하기
  sudo update-alternatives --install /usr/bin/python python /usr/local/bin/python3.8 1
  sudo update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip3.8 1
}

#python_install
#spark_isntall