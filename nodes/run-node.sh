#!/bin/bash
function leader_ip {
    echo $(curl -s http://rancher-metadata/2015-12-19/containers/$1-$2-1/primary_ip)
}

stack_name=`curl -s http://rancher-metadata/2015-12-19/self/stack/name`

port=`curl -s http://rancher-metadata/2015-12-19/self/container/ports/0| sed  "s/.*:\([0-9]\{3,6\}\)\(\/tcp\|\/http\)\?/\1/g"`

node_ip=`echo $(curl -s http://rancher-metadata/2015-12-19/self/container/primary_ip)`

master_ip=$(leader_ip $stack_name "redis")

echo "node_ip=$node_ip"
echo "master_ip=$master_ip"
echo "stack_name=$stack_name"
echo "port=$port"

sed -i "s/%port%/$port/g" /etc/redis/redis.conf

if [ "$node_ip" == "$master_ip" ]
then
   echo "I'm the leader"
else
    echo "slaveof $master_ip $port" >> /etc/redis/redis.conf
fi

redis-server /etc/redis/redis.conf
