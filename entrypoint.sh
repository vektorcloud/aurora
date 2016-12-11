#!/usr/bin/dumb-init /bin/bash

set -e

PIDS=""

export MESOS_MASTER="zk://$AURORA_ZK/mesos"

[ -n "$WITH_SCHEDULER" ] && {

  if [ ! -d "/var/lib/aurora/scheduler/db" ]; then
    mkdir -vp /var/lib/aurora/scheduler/db
    mesos-log initialize --path="/var/lib/aurora/scheduler/db"
  fi

  /usr/share/aurora/bin/aurora-scheduler -cluster_name="aurora" \
        -http_port="8081" \
        -native_log_quorum_size="$AURORA_QUORUM" \
        -zk_endpoints="$AURORA_ZK" \
        -mesos_master_address="$MESOS_MASTER" \
        -serverset_path="/aurora/scheduler" \
        -native_log_zk_group_path="/aurora/replicated-log" \
        -native_log_file_path="/var/lib/aurora/scheduler/db" \
        -backup_dir="/var/lib/aurora/scheduler/backups" \
        -thermos_executor_path="/usr/share/aurora/bin/thermos_executor.pex" \
        -thermos_executor_resources="" \
        -thermos_executor_flags="--announcer-ensemble $AURORA_ZK" \
        -allowed_container_types="MESOS,DOCKER" &
  PIDS="$PIDS $!"
}

# Launches Mesos Agent & Thermos
[ -n "$WITH_WORKER" ] && {
  /usr/sbin/mesos-agent &
  PIDS="$PIDS $!"
  /usr/sbin/thermos_observer &
  PIDS="$PIDS $!"
}

# Wait for all processes to complete.
# TODO: Script should exit if ANY process exits
if [ "$PIDS" != "" ]; then
  wait $PIDS
else
  exec "$@"
fi
