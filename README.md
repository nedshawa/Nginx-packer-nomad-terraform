# Packer and Terraform Tutorial

In this tutroial, I am showing how we can create an AMI on AWS using packer,
followed by a build of a Consul cluster using Terraform with the basic Apache
server service registered with consul and consul UI.

## Getting Started

The flow goes as follows:

- Packer will create an AMI based on RHEL 7 on AWS, this will include all what
you need for consul servers and clients.
- Terraform will build the cluster based on the variables supplied within the
terraform runtime folder, followed by starting up the consul cluster and the
Apache service.

The Packer folder consists of the following:

- consul_cluster.json : This is the file where all the AMI specific details are
being stored, such as the name of the AMI, type of base AMI used..etc usually you
dont need to modify this file.
- script.sh : this is the script that runs on top of the base AMI to create the new AMI.

The Terraform folder consists of the following:

main.tf : this is the main terraform body that runs and creates the cluster,
you dont usually need to modify this file.

variables.tf : this is the variables where you might want to change the instance type,
default is t2.micro, also the size of the cluster, you can specify the no. of consul
servers and the no. of clients.

scripts/consul.service : this defines the consul service for systemctl SVM in RHEL 7
scripts/configConsul : this is where the service configuration for consul and apache happens
depending whether the node is a client or a server.
by defualt once the count of the consul servers is reached, the clients portion will run
using the script.


### Prerequisites

The only Prerequisites here are the following:

- Active AWS account
- Download the latest HashiCorp Packer and Terraform.
- IAM role that is allowed to create instances, security groups..etc (admin role)
- make sure to export your AWS_ACCESS_KEY and AWS_SECRET_ACCESS_KEY to your Environment
best if you can add it to your bash_profile so you dont have to export it often


```
export AWS_ACCESS_KEY_ID=AKIAIMUxxxxxxx
export AWS_SECRET_ACCESS_KEY=Gud+ZHXj4LvGHJ261sxxxxxxxxxxxx

```
you also need to have an active SSH key pair for Terraform cluster building,
 if you dont have one, you can generate them using

```
ssh-keygen ~/.ssh/deployer-key
```


### Installing

Clone or download the code directly to your machine.

```
git clone https://github.com/nedshawa/project.git
```

## Deployment

Creating the AMIs needed for Terraform using Packer:

- Go to Packer folder

```
packer consul_cluster.json
```

AMI building will start and will result in an ami_id at the end

Creating the Cluster using Terraform

Modify the variables.tf file, and make sure you change the following variables:

```
public_key_path // from your recently created ssh key pair
private_key_path // from your recently created ssh key pair
ami // from the resuling ami_id after running packer

```

you can change the region,cluster size and instance type if required.

you can also add your AWS keys values into the variables if you dont want to export
them to the env.


Plan the execution (dry run)
```
terraform plan
```

if you are happy then:

Execute the plan
```
terraform apply
```

once the deployment is over, Terraform will print the public address for one
of the consul-server nodes so you can connect to.

to test the consul-ui go to:

http://the-public-dns-node-name:8500/ui
