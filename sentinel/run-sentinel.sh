#!/bin/bash
function leader_ip {
    echo $(curl -s http://rancher-metadata/2015-12-19/containers/$1-$2-1/primary_ip)
}

stack_name=`curl -s http://rancher-metadata/2015-12-19/self/stack/name`

sentinel_port=`curl -s http://rancher-metadata/2015-12-19/self/container/ports/0| sed  "s/.*:\([0-9]\{3,6\}\)\(\/tcp\|\/http\)\?/\1/g"`

redis_port=`curl -s http://rancher-metadata/2015-12-19/services/redis/ports/0| sed  "s/.*:\([0-9]\{3,6\}\)\(\/tcp\|\/http\)\?/\1/g"`

node_ip=`echo $(curl -s http://rancher-metadata/2015-12-19/self/container/primary_ip)`

master_ip=$(leader_ip $stack_name "redis")

echo "node_ip=$node_ip"
echo "master_ip=$master_ip"
echo "stack_name=$stack_name"
echo "sentinel_port=$sentinel_port"
echo "redis_port=$redis_port"

sed -i "s/%sentinel_port%/$sentinel_port/g" /etc/redis/sentinel.conf
sed -i "s/%redis_port%/$redis_port/g" /etc/redis/sentinel.conf
sed -i "s/%master_ip%/$master_ip/g" /etc/redis/sentinel.conf
sed -i "s/%node_ip%/$node_ip/g" /etc/redis/sentinel.conf

redis-sentinel /etc/redis/sentinel.conf
