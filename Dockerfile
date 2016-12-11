FROM ubuntu:latest

RUN apt-get update && \
  apt-get install -yyq wget \
  openjdk-8-jre \
  curl \
  subversion \
  libcurl4-nss-dev \
  libcurlpp-dev \
  python \
  python-dev \
  openssl && \
  wget "https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64.deb" -O /tmp/dumb_init.deb && \
  dpkg --install /tmp/dumb_init.deb && \
  rm /tmp/dumb* && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Mesos
RUN VERSION="1.1.x" && \
  PACKAGE="mesos-$VERSION-glibc.tar.gz" && \
  wget "https://github.com/vektorlab/mesos-packaging/releases/download/$VERSION/$PACKAGE" -O "/tmp/$PACKAGE" && \
  wget "https://github.com/vektorlab/mesos-packaging/releases/download/$VERSION/$PACKAGE.md5" -O "/tmp/$PACKAGE.md5" && \
  cd /tmp && \
  md5sum -c "$PACKAGE.md5" && \
  mkdir /tmp/mesos && \
  tar xvf "/tmp/$PACKAGE" -C / && \
  rm -rvf /tmp/*

# Aurora
RUN VERSION="0.16.0" && \
  PACKAGE="aurora-scheduler_${VERSION}_amd64.deb" && \
  wget "https://apache.bintray.com/aurora/ubuntu-trusty/$PACKAGE" -O "/tmp/$PACKAGE" && \
  dpkg --ignore-depends=mesos --install "/tmp/$PACKAGE"  && \
  rm -v "/tmp/$PACKAGE" && \
  PACKAGE="aurora-executor_${VERSION}_amd64.deb" && \
  wget "https://apache.bintray.com/aurora/ubuntu-trusty/$PACKAGE" -O "/tmp/$PACKAGE" && \
  dpkg --ignore-depends=mesos --install "/tmp/$PACKAGE" && \
  rm -v "/tmp/$PACKAGE" && \
  PACKAGE="aurora-tools_${VERSION}_amd64.deb" && \
  wget "https://apache.bintray.com/aurora/ubuntu-trusty/$PACKAGE" -O "/tmp/$PACKAGE" && \
  dpkg --ignore-depends=mesos --install "/tmp/$PACKAGE" && \
  rm -v "/tmp/$PACKAGE"

ENV GLOG_v="0"
ENV LIBPROCESS_PORT="8083"
ENV JAVA_OPTS="-Djava.library.path=/usr/local/lib"
ENV MESOS_NATIVE_JAVA_LIBRARY="/usr/lib/libmesos.so"

ENV AURORA_ZK="localhost:2181"
ENV AURORA_QUORUM="1"

# Set as thermos_mesos_root flag
ENV MESOS_WORK_DIR="/opt/mesos"
ENV MESOS_CONTAINERIZERS="docker,mesos"
# https://mesosphere.github.io/marathon/docs/native-docker.html
ENV MESOS_EXECUTOR_REGISTRATION_TIMEOUT="5mins"
# https://issues.apache.org/jira/browse/MESOS-3793
ENV MESOS_LAUNCHER="posix"
ENV MESOS_SYSTEMD_ENABLE_SUPPORT="false"


COPY entrypoint.sh /

EXPOSE "1338"
EXPOSE "5051"
EXPOSE "8081"
EXPOSE "8083"

ENTRYPOINT ["/entrypoint.sh"]
