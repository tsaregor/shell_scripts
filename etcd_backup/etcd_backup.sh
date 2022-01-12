#! /bin/bash

BACKUP_DIR='/opt/backup/etcd'
BACKUP_FULL_NAME="$BACKUP_DIR/etcd.snap"
PR_DAY=100

if [ ! -d $BACKUP_DIR ]; then
  echo "Backups dir not exists"
  exit 1
fi

### rotation
for ((i=$PR_DAY-2; i >= 0;i--)); do
  if [ -f $BACKUP_FULL_NAME".$i" ]; then
	  mv $BACKUP_FULL_NAME".$i" $BACKUP_FULL_NAME".$(($i+1))"
  fi
done
if [ -f $BACKUP_FULL_NAME ]; then
  mv $BACKUP_FULL_NAME $BACKUP_FULL_NAME".0"
fi

### etcd snap
ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 --cert=/etc/kubernetes/pki/etcd/server.crt --key=/etc/kubernetes/pki/etcd/server.key --cacert=/etc/kubernetes/pki/etcd/ca.crt snapshot save $BACKUP_FULL_NAME
if [ $? -ne 0 ]; then
  echo "Backup error"
  cp $BACKUP_FULL_NAME".0" $BACKUP_FULL_NAME".preserve"
  exit 1
fi

echo "Backup ok"
exit 0
