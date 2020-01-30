#main.tf
#   like main.c, terraform starts here.  This file serves to tell terraform how
#   you want to initialize and deploy.  
#   
#   TODO: 
#     + describe how other files complement this
#     + do not hard-code key_name, consider a tool like AWS-vault or similar

#Set the provider and any provider-specific config
#From terraform docs:
#    A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS (e.g. Alibaba Cloud, AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS services (e.g. Terraform Cloud, DNSimple, Cloudflare).
provider "aws" {
  region = "us-east-1"
}

#Define a resource the provider knows about (basically, this is one of the ways terraform APIs and provider APIs talk)
#In this case, a jumphost named captain
resource "aws_instance" "captain" {
  ami           = "ami-01d9d5f6cecc31f85"  #The Amazon Machine Image, basically your resource's base OS
  instance_type = "t2.micro"               #Type of resource, see AWS docs, t2.micro is free and good to start with
  key_name      = "ajacobs-IAM-keypair"    #You must have setup keypairs with Amazon and a proper .pem file

  #user_data is one of the ways you can setup your "early" system, getting the very basics available and no more
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -      
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
              sudo apt-get update
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io
              EOF

  tags = {
    Name = "captain"
  }
}

#Create a new resource, this time a t2.medium EC2 instance with 6 nodes
resource "aws_instance" "resource_server_medium" {
  ami           = "ami-01d9d5f6cecc31f85"
  instance_type = "t2.medium"
  count         = 6
  key_name      = "ajacobs-IAM-keypair"

  tags = {
    Name = "resource_server_medium"
  }
}

#Create a new resource, this time a t2.micro EC2 instance with 6 nodes
resource "aws_instance" "resource_server_micro" {
  ami           = "ami-01d9d5f6cecc31f85"
  instance_type = "t2.micro"
  count         = 6
  key_name      = "ajacobs-IAM-keypair"

  tags = {
    Name = "resource_server_micro"
  }
}

#Print the captain's public id to the terminal after things like terraform apply or refresh
output "captain_public_ip" {
  value = ["${aws_instance.captain.public_ip}"]
}

output "resource_server_medium_public_ips" {
  value = ["${aws_instance.resource_server_medium.*.public_ip}"]
}

output "resource_server_micro_public_ips" {
  value = ["${aws_instance.resource_server_micro.*.public_ip}"]
}
