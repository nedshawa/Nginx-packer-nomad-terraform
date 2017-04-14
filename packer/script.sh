#!/bin/bash
sudo yum -y update
sudo yum install -y wget unzip
wget https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_linux_amd64.zip
unzip nomad_0.5.6_linux_amd64.zip
rm nomad_0.5.6_linux_amd64.zip
