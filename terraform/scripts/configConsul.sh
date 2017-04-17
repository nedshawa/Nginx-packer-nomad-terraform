#!/usr/bin/env bash
set -e

echo "Read from /tmp into ENV....."

export SERVER_COUNT=`cat /tmp/consul-server-count`
export CONSUL_JOIN=`cat /tmp/consul-server-addr`
export CONSUL_DC=`cat /tmp/consul-datacenter`

cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data datacenter=${CONSUL_DC}"
EOF

echo "Configuring Consul Services...."


sudo mv /tmp/consul.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/consul.service
sudo chmod 664 /etc/systemd/system/consul.service
sudo mv /tmp/consul_flags /etc/sysconfig/consul
sudo chown root:root /etc/sysconfig/consul
sudo chmod 664 /etc/sysconfig/consul

echo "Starting Consul...."

  sudo systemctl enable consul.service
  sudo systemctl start consul
