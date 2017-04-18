provider "aws" {
  region = "${var.region}"
}

resource "aws_instance" "server" {
  ami =  "${var.ami}"
  instance_type = "${var.instance_type}"
  security_groups = ["${aws_security_group.consul.name}"]
  key_name = "${aws_key_pair.deployer.key_name}"
  count = "${var.consul_cluster_count}"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
tags {
  Name = "consul-node-${count.index+1}"
        Environment = "production"
        Role = "consul"
}
connection {
       user = "${var.aws_user}"
       private_key = "${file("${var.private_key_path}")}"
   }
provisioner "remote-exec" {
    inline = [
      "echo ${var.consul_servers_count} > /tmp/consul-server-count",
         "echo ${aws_instance.server.0.private_ip} > /tmp/consul-server-addr",
         "echo ${var.region} > /tmp/consul-datacenter",
         "echo ${count.index+1} > /tmp/instance_count",
         "echo ${var.consul_cluster_count} > /tmp/cluster_count",
         "echo ${self.private_ip} > /tmp/private_ip",
        "echo ${self.public_ip} > /tmp/public_ip",
    ]
}

provisioner "file" {
    source      = "services/consul.service"
    destination = "/tmp/consul.service"
  }
  provisioner "file" {
      source      = "services/nomad.service"
      destination = "/tmp/nomad.service"
    }
    provisioner "file" {
        source      = "scripts/nginx.nomad"
        destination = "/tmp/nginx.nomad"
      }
provisioner "remote-exec" {
        scripts = [
            "${path.module}/scripts/config.sh",
        ]
    }

}

resource "aws_key_pair" "deployer" {
key_name = "deployer-key"
public_key = "${file("${var.public_key_path}")}"
}
resource "aws_security_group" "consul" {
  name = "consul-cluster-security"
  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Allow ports for SSH connectivity
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //Allow ports for Consul services
  ingress {
    from_port = "8300"
    to_port = "8302"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "8300"
    to_port = "8302"
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "8400"
    to_port = "8400"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "8500"
    to_port = "8500"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "8600"
    to_port = "8600"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "8600"
    to_port = "8600"
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //allow port for Apache http access
  ingress {
    from_port = "80"
    to_port = "80"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //Allow ports for Nomad http,rpc,serf
  ingress {
    from_port = "4646"
    to_port = "4648"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "4646"
    to_port = "4648"
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow all ports to the outside
  egress {
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
