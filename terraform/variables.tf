#variable "access_key" {}     //fill if its not exported to your env
#variable "secret_key" {}     //fill if its not exported to your env
variable "public_key_path" {default =  "~/.ssh/deploy-key.pub"} //Path to your public key
variable "private_key_path" {default = "~/.ssh/deploy-key.pem"} //path to your private key
variable "ami"  { default = "ami-2a737a49"} //the ami id that was produced by packer
variable "aws_user" {default = "ec2-user"}
variable "region" { default = "ap-southeast-2" }
variable "consul_servers_count" {default = "3"}
variable "consul_cluster_count" {default = "5"}
variable "instance_type" {default = "t2.micro"}
variable "azs" {
    default = {
        "ap-southeast-2" = "ap-southeast-2a,ap-southeast-2b"}
}
