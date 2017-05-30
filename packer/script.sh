#!/bin/bash
echo "Yum update and Downloading wget and unzip..."
sudo yum -y update
sudo yum install -y wget unzip
echo "Fetching Nomad..."
wget https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_linux_amd64.zip
echo "Fetching Consul..."
wget https://releases.hashicorp.com/consul/0.8.0/consul_0.8.0_linux_amd64.zip
echo "Unzipping Nomad and Consul..."
sudo unzip nomad_0.5.6_linux_amd64.zip
sudo unzip consul_0.8.0_linux_amd64.zip
echo "Creating Directories and house keeping..."
sudo rm nomad_0.5.6_linux_amd64.zip
sudo rm consul_0.8.0_linux_amd64.zip
sudo chmod +x nomad
sudo chmod +x consul
sudo mv nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d
sudo mv consul /usr/bin/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /mnt/consul
sudo mkdir -p /etc/service
