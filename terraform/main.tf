provider "aws" {
  region = "${var.region}"
}
data "aws_availability_zones" "all" {}
output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}
resource "aws_launch_configuration" "project" {
  image_id =  "ami-677c7504"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  key_name = "${aws_key_pair.deployer.key_name}"
  lifecycle {
	create_before_destroy = true
	}
}

resource "aws_key_pair" "deployer" {
key_name = "deployer-key"
public_key = "${file("${var.public_key_path}")}"
}
resource "aws_security_group" "instance" {
  name = "terraform-instance"
  ingress {
    from_port = "8080"
    to_port = "8080"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "22"
    to_port = "22"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
lifecycle {
        create_before_destroy = true
        }
}
resource "aws_autoscaling_group" "asg" {
launch_configuration = "${aws_launch_configuration.project.id}"
 availability_zones = ["${data.aws_availability_zones.all.names}"]
  min_size = 2
  max_size = 10
  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "terraform-asg"
    propagate_at_launch = true
  }
}
resource "aws_elb" "elb"{
 	name= "terraform-elb"
 	security_groups = ["${aws_security_group.elb.id}"]
 	availability_zones = ["${data.aws_availability_zones.all.names}"]
 	listener{
	 lb_port = 80
	 lb_protocol = "http"
	 instance_port = 8080
	 instance_protocol = "http"
}
	health_check {
	 healthy_threshold = 2
   	 unhealthy_threshold = 2
   	 timeout = 3
    	 interval = 30
    	 target = "HTTP:80/"
  }
}
resource "aws_security_group" "elb" {
	name = "terraform-elb"

	egress{
	 from_port = 0
    	 to_port = 0
     	protocol = "-1"
    	cidr_blocks = ["0.0.0.0/0"]
  }
	ingress{
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks =  [ "0.0.0.0/0"]
}
}
