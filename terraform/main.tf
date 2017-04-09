provider "aws" {
  region = "ap-southeast-2"
}
resource "aws_instance" "node1" {
  ami =  "ami-46202e25"
  instance_type = "t2.micro"
tags {
    Name = "terraform-node1"
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-node1-instance"
  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
