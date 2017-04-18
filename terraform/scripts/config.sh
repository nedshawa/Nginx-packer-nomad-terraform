#!/usr/bin/env bash
set -e

echo "Read from /tmp into ENV....."

export SERVER_COUNT=`cat /tmp/consul-server-count`
export CONSUL_JOIN=`cat /tmp/consul-server-addr`
export CONSUL_DC=`cat /tmp/consul-datacenter`
export INSTANCE_COUNT=`cat /tmp/instance_count`
export PRIVATE_IP=`cat /tmp/private_ip`
export PUBLIC_IP=`cat /tmp/public_ip`

sudo mkdir /etc/nomad
if [ ${INSTANCE_COUNT} -lt 4 ]; then
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-server -bootstrap-expect=${SERVER_COUNT} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data -datacenter=${CONSUL_DC} -ui -client=${PRIVATE_IP}"
EOF
cat >/tmp/server.hcl << EOF
log_level = "DEBUG"
data_dir = "/tmp/nomad"
bind_addr = "0.0.0.0"
leave_on_terminate = true
advertise {
  http = "${PRIVATE_IP}:4646"
  rpc = "${PRIVATE_IP}:4647"
  serf = "${PRIVATE_IP}:4648"
}
server {
  enabled = true
  bootstrap_expect = 3
}
consul {
  server_service_name = "nomad"
  server_auto_join = true
  client_service_name = "nomad-client"
  client_auto_join = true
  auto_advertise = true
  address = "${CONSUL_JOIN}:8500"
  server_service_name = "nomad"
}
EOF
else
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-join=${CONSUL_JOIN} -data-dir=/opt/consul/data -datacenter=${CONSUL_DC} -config-dir=/etc/consul"
EOF
sudo mv /tmp/server.hcl /etc/nomad
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo mkdir /etc/consul/
sudo chmod 777 /etc/consul
sudo echo "<h1>This is the Web Server of Node $HOSTNAME</h1>" | sudo tee /var/www/html/index.html
sudo cat << EOF > /etc/consul/web.json
{
  "service": {
    "name": "apache",
    "tags": ["web"],
    "address": "${PRIVATE_IP}",
    "port": 80,
    "enableTagOverride": false,
    "checks": [
      {
        "tcp": "localhost:80",
        "interval": "10s"
      }
    ]
  }
}
EOF
cat < /tmp/client.hcl << EOF
log_level = "DEBUG"
data_dir = "/tmp/nomad"
client {
  enabled = true
}
leave_on_terminate = true
consul {
  address = "${CONSUL_JOIN}:8500"
  server_service_name = "nomad"
  server_auto_join = true
  client_service_name = "nomad-client"
  client_auto_join = true
  auto_advertise = true
}
EOF
sudo mv /tmp/client.hcl /etc/nomad
fi


echo "Configuring Consul and Nomad Services...."

sudo yum install -y bind-utils
#sudo chmod 755 /etc/dnsmasq.d
#sudo bash -c 'cat >/etc/dnsmasq.d/10-consul << EOF
#server=/consul/127.0.0.1#8600
#EOF'
#sudo bash -c 'cat >/etc/resolv.conf << EOF
#nameserver 127.0.0.1
#EOF'
sudo mv /tmp/consul.service /etc/systemd/system/
sudo chown root:root /etc/systemd/system/consul.service
sudo chmod 664 /etc/systemd/system/consul.service
sudo mv /tmp/nomad.service /etc/systemd/system
sudo chown root:root /etc/systemd/system/consul.service
sudo chmod 664 /etc/systemd/system/consul.service
sudo mv /tmp/consul_flags /etc/sysconfig/consul
sudo chown root:root /etc/sysconfig/consul
sudo chmod 664 /etc/sysconfig/consul

echo "Starting Consul and Nomad"

  sudo systemctl enable consul.service
  sudo systemctl enable nomad.service
  sudo systemctl start consul
  sudo systemctl start nomad
