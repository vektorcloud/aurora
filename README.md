# Apache Aurora

[Apache Aurora](http://aurora.apache.org/) in Docker.


### Running


    docker run -d --net host -e WITH_ZOOKEEPER=1 -e WITH_MESOS_MASTER=1 quay.io/vektorcloud/mesos
    docker run --rm -ti --rm --net host -v /var/run/docker.sock:/var/run/docker.sock -v $(which docker):/usr/bin/docker -e WITH_SCHEDULER=1 -e WITH_WORKER=1 quay.io/vektorcloud/aurora
