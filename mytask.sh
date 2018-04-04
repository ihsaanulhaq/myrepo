#!/bin/bash

cd /home/xflow/ovs
ovs-vsctl --version
RESULT=$?

#check if repo is uptodate
if [ $RESULT == 0 ]; then
  OUTPUT=`git pull`
  while [[ $OUTPUT == *"Already up-to-date"* ]]; do
    echo "Up-to-date..."
    sleep 5s
    break
  done
fi

#remove old, clone & install afresh
cd /home/xflow
rm -rf /home/xflow/ovs


git clone https://github.com/openvswitch/ovs.git
cd ovs
if ! [ -x "$(command -v autoreconf)" ]; then
  echo 'Error: autoreconf is not installed.' >&2
  apt install autoconf -y
fi
./boot.sh
./configure
make
make install

ovs-vsctl --version
RESULT=$?
if [ $RESULT == 0 ]; then
  echo OVS successfully installed...
else
  echo Installation failed...
fi


