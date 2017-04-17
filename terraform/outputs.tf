output "server_address" {
	value = "${aws_instance.consul_server.0.public_dns}"
}
