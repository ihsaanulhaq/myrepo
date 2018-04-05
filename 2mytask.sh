#!/bin/bash

function f1(){
cd /home/xflow/ovs
ovs-vsctl --version
RESULT=$?

#check if repo is uptodate
if [ $RESULT == 0 ]; then
  OUTPUT=`git pull`
  while [[ $OUTPUT == *"Already up-to-date"* ]]; do
    echo "Up-to-date..."
    sleep 2s
    break
  done
fi
}

function f2(){
#remove old, clone & install afresh
cd /home/xflow
rm -rf /home/xflow/ovs


git clone https://github.com/openvswitch/ovs.git
}

function f3(){
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
}

function f4(){

echo milestone-2.....

ovs-vsctl del-br mybr1
ovs-vsctl add-br mybr1 -- set Bridge mybr1 fail-mode=secure
ovs-vsctl add-port mybr1 ens5
ovs-ofctl add-flow mybr1 "in_port=1,ip,nw_src=192.168.10.191,actions=drop"
#ovs-ofctl dump-tables-desc mybr1
}

function f5(){
for ((i=1; i<=100; i++))
do
  ovs-ofctl add-flow mybr1 "in_port=1,ip,nw_src=192.168.10.$i,actions=drop"
  #echo rule-$i installed...
done
ovs-ofctl dump-flows mybr1
#echo Execution finished....
}

f1
#f2
#f3
f4
f5


if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ];
then
  sudo apt-get install apache2 -y;
  sudo service apache2 start
fi


#file = `/var/www/html/my1.html`
#cd /home/xflow/ovs
#cd /home/xflow/myrepo
cd /home/xflow/ovs
sudo rm /var/www/html/my1.html
echo Successful  >> /var/www/html/my1.html
#sudo git log --name-status HEAD^..HEAD >> /var/www/html/my1.html
sudo git rev-list --format=format:'%ai' --max-count=5 `git rev-parse HEAD` >> /var/www/html/my1.html
#sudo service apache2 reload
echo Finishedddd
