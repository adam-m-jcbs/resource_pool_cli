provider "aws" {
  region = "us-east-1"
}

variable "num_of_resource_servers" {
  default = 2
}

resource "aws_instance" "captain" {
  ami           = "ami-01d9d5f6cecc31f85"
  instance_type = "t2.micro"
  key_name      = "grlaracuente-IAM"

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -      
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              sudo docker pull ansible/ansible:default
              EOF

  tags = {
    Name = "captain"
  }
}

resource "aws_instance" "resource_server" {
  ami           = "ami-01d9d5f6cecc31f85"
  instance_type = "t2.micro"
  count         = var.num_of_resource_servers
  key_name      = "grlaracuente-IAM"

  tags = {
    Name = "resource_server"
  }
}

output "captain_public_ip" {
  value = ["${aws_instance.captain.public_ip}"]
}

output "captain_private_ip" {
  value = ["${aws_instance.captain.private_ip}"]
}

output "resource_server_public_ips" {
  value = ["${aws_instance.resource_server.*.public_ip}"]
}

output "resource_server_private_ips" {
  value = ["${aws_instance.resource_server.*.private_ip}"]
}

