#main.tf
#   like main.c, terraform starts here.  This file serves to tell terraform how
#   you want to initialize and deploy your infrastructure.  
#   

#Set the provider and any provider-specific config
#From terraform docs:
#    A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS (e.g. Alibaba Cloud, AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS services (e.g. Terraform Cloud, DNSimple, Cloudflare).
provider "aws" {
  region = "us-east-1"
  version = "~> 2.0"
}

#Define a AWS resource the provider knows about (basically, this is one of the
#ways terraform APIs and provider APIs talk) In this case, a jumphost named captain
#  For aws_instance documentation, see e.g. https://www.terraform.io/docs/providers/aws/r/instance.html
#  TODO: Add a corresponding data resource, like:
#  
#  data "aws_ami" "ubuntu" {
#    most_recent = true
# 
#    filter {
#      name   = "name"
#      values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
#    }
# 
#    filter {
#      name   = "virtualization-type"
#      values = ["hvm"]
#    }
# 
#    owners = ["099720109477"] # Canonical
#  }
#
#  This will help further minimize the amount of by-hand setup users have to do.
#  I don't want them to have to execute setup.sh.
resource "aws_instance" "captain" {
  ami           = "ami-01d9d5f6cecc31f85"  #The Amazon Machine Image, basically your resource's base OS
  instance_type = "t2.micro"               #Type of resource, see AWS docs, t2.micro is free and good to start with
  key_name      = "ajacobs-IAM-keypair"    #You must have setup keypairs with Amazon and a proper .pem file
  #user_data is one of the ways you can setup your "early" system, getting the very basics needed for your users to be productive
  user_data = <<-EOF
              #!/bin/bash

              #best practice to update the root system early, especially as security and bug fixes are pushed frequently
              #    if the latest system breaks your infra, you want to know sooner, not later
              sudo apt-get update
              sudo apt-get upgrade

              #now that our base is upgraded, install basic software needed for next steps and useful for users at a system-wide level
              sudo apt-get install -y curl software-properties-common
              
              #enable security best practices and secure access to trusted sources in a mutually authenticated framework
              sudo apt-get install -y apt-transport-https ca-certificates gnupg-agent

              #authenticate with our software provider (essentially docker in this case) and add their repositories to our package database 
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -      
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

              #install needed docker components, first bringing in repo upgrades, and then applying any upgrades triggered by docker
              sudo apt-get update
              sudo apt-get upgrade
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io

              #install utilities
              sudo apt-get install -y htop
              EOF

  tags = {
    Name = "captain"
  }

  #As a pragmatic matter I'm using provisioners.  But note these hinder terraform's ability to properly lay out plans for complex infrastructure.  Provisioners should be eliminated to maximize infra maintainabililty and stability.
  #provisioner "file" {
  #  source      = "../user_facing/1-setup-env.sh"
  #  destination = "/var/tmp/1-setup-env.sh"
  #  
  #  connection {
  #    type     = "ssh"
  #    user     = "ubuntu"
  #    private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
  #    #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
  #    host     = "${aws_instance.captain.public_ip}"
  #  }
  #  
  #}

  provisioner "file" {
    source      = "../user_facing"
    destination = "/var/tmp"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
    
  }

  #securely provision secrets - only root users can see this
  provisioner "file" {
    source      = "../_donottrack/ajacobsdocid_access_token.txt"
    destination = "/var/tmp/doc_acc_tok"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
    
  }


  #provisioner "local-exec" {
  #  command = "echo hec2-3-84-41-174.compute-1.amazonaws.comey I am running on your machine"
  #}
  
  provisioner "remote-exec" {
    inline = [
      "cd /var/tmp/user_facing/",
      "echo 'source 1-setup-env.sh; source 2-setup-mkdirs.sh; source 3-setup-extractplaybooks.sh; source 4a-setup-install.sh; source 4b-setup-install.sh' | sudo bash "
    ]
    # "echo 'hostname -b captain-node' | sudo bash ", #cute, but it broke networking... don't play with hostnames
    #  "echo '; source 4a-setup-install.sh; source 4b-setup-install.sh' | sudo bash "
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
  }
}

#Enable use of allocated eip
resource "aws_eip" "public_igw" {
  vpc = true
}

#Create the smallest ever VPC, mostly for elastic ip
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.captain.id}"
  allocation_id = "${aws_eip.public_igw.id}"
}

#Create a new resource, this time a t2.medium EC2 instance with 6 nodes
#TODO: rename server --> cluster (k8s or trad datacenter), more accurate
#resource "aws_instance" "resource_server_medium" {
#  ami           = "ami-01d9d5f6cecc31f85"
#  instance_type = "t2.medium"
#  count         = 6
#  key_name      = "ajacobs-IAM-keypair"
#
#  tags = {
#    Name = "resource_server_medium"
#  }
#}
##
##Create a new resource, this time a t2.micro EC2 instance with 6 nodes
#resource "aws_instance" "resource_server_micro" {
#  ami           = "ami-01d9d5f6cecc31f85"
#  instance_type = "t2.micro"
#  count         = 6
#  key_name      = "ajacobs-IAM-keypair"
#
#  tags = {
#    Name = "resource_server_micro"
#  }
#}

#Print the captain's public id to the terminal after things like terraform apply or refresh
output "captain_public_ip" {
  value = [
    "${aws_instance.captain.public_ip}",
    "${aws_instance.captain.private_ip}",
    "${aws_instance.captain.public_dns}"
  ]
  #value = ["${aws_instance.captain.public_ip} ${aws_instance}"]
}

#output "resource_server_medium_public_ips" {
#  value = ["${aws_instance.resource_server_medium.*.public_ip}"]
#}
#
#output "resource_server_micro_public_ips" {
#  value = ["${aws_instance.resource_server_micro.*.public_ip}"]
#}
output "igw_eip" {
  value = ["${aws_eip_association.eip_assoc.*}"]
}