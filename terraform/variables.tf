variable "public_key_path" {default =  "~/.ssh/deploy-key.pub"}
variable "private_key_path" {default = "~/.ssh/deploy-key.pem"}
variable "aws_user" {default = "ec2-user"}
#variable "access_key" {}
#variable "secret_key" {}
variable "region" { default = "ap-southeast-2" }
variable "ami"  { default = "ami-2a737a49"}
variable "consul_servers_count" {default = "3"}
variable "instance_type" {default = "t2.micro"}
variable "azs" {
    default = {
        "ap-southeast-2" = "ap-southeast-2a,ap-southeast-2b"}
}
