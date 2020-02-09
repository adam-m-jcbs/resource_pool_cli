#main.tf
#   TODO: break up into variables.tf, tf_llhike main.c, terraform starts here.  This file serves to tell terraform how
#   you want to initialize and deploy your infrastructure.  
#   

#######################
###### PROVIDER #######
#######################
#Set the provider and any provider-specific config
#From terraform docs:
#    A provider is responsible for understanding API interactions and exposing resources. Providers generally are an IaaS (e.g. Alibaba Cloud, AWS, GCP, Microsoft Azure, OpenStack), PaaS (e.g. Heroku), or SaaS services (e.g. Terraform Cloud, DNSimple, Cloudflare).
provider "aws" {
  region = "us-east-1"
  version = "~> 2.0"
}


#######################
###### VPC/NET   ######
#######################

resource "aws_vpc" "resource_pool_vpc" {
  cidr_block = "10.0.1.0/28" # 10.0.1.0 -- 10.0.1.15
  
  tags = {
    Name = "Unified Resource Pool VPC"
  }

  #Potentially useful attributes, current values from state:
  #  "arn": "arn:aws:ec2:us-east-1:573419053708:vpc/vpc-0d0bb7447d5419d29",
  #  "default_network_acl_id": "acl-04b6adc0922bfbe8c",
  #  "default_route_table_id": "rtb-006a9d1d2401adc04",
  #  "main_route_table_id": "rtb-006a9d1d2401adc04",
  #  "default_security_group_id": "sg-08c5476c3ca0475b3",
  #  "dhcp_options_id": "dopt-aa9f53d0",
  #  "enable_dns_hostnames": true,
  #  "enable_dns_support": true,
  #  "id": "vpc-0d0bb7447d5419d29",
  #  "instance_tenancy": "default",
  #  "ipv6_association_id": "",
  #  "ipv6_cidr_block": "",
  #  "owner_id": "573419053708",

}

#For now, just including everyone.  Should instead use multiple subnets with redundancies/good separation
resource "aws_subnet" "resource_pool_subnet" {
  vpc_id = "${aws_vpc.resource_pool_vpc.id}"
  cidr_block = "10.0.1.0/28"  # 10.0.1.0 - 10.0.1.7
  #availability_zone = "us-east-1a"

  tags = {
    Name = "Unified Resource Pool VPC"
  }
}


resource "aws_network_interface" "resource_pool_netface" {
  subnet_id   = "${aws_subnet.resource_pool_subnet.id}"
  #private_ips = ["10.0.1.3"]

  tags = {
    Name = "primary_network_interface"
  }
}

##Enable use of allocated eip
resource "aws_eip" "public_igw" {
  vpc = true

  tags = {
    Name = "public_igw"
  }
}
#
#Associate elastic ips
resource "aws_eip_association" "eip_captain_assoc" {
  instance_id   = "${aws_instance.captain.id}"
  allocation_id = "${aws_eip.public_igw.id}"
}

resource "aws_eip" "rp_igw" {
  vpc = true

  tags = {
    Name = "rp_igw"
  }
}

resource "aws_eip_association" "eip_rp_assoc" {
  instance_id   = "${aws_instance.resource_server_medium[0].id}"
  allocation_id = "${aws_eip.rp_igw.id}"
}

#####################################
###### Compute / Host Resources #####
#####################################
#    template:
#    resource "type" "name" {
#      resource_attribute = value
#    }

resource "aws_instance" "captain" {
  ami           = "ami-01d9d5f6cecc31f85"  #The Amazon Machine Image, basically your resource's base OS
  #instance_type = "t2.micro"               #Type of resource, see AWS docs, t2.micro is free and good to start with
  instance_type = "t2.medium"
  key_name      = "ajacobs-IAM-keypair"    #You must have setup keypairs with Amazon and a proper .pem file
  associate_public_ip_address = false # public connections to this machine are managed through dynamic elastic ips 
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

              #install utilities
              sudo apt-get install -y htop

              #authenticate with our software provider (essentially docker in this case) and add their repositories to our package database 
              sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -      
              sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

              #install needed docker components, first bringing in repo upgrades, and then applying any upgrades triggered by docker
              sudo apt-get update
              sudo apt-get upgrade
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io

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

  #network_interface {
  #  network_interface_id = "${aws_network_interface.resource_pool_netface.id}"
  #  device_index         = 0
  #}

  credit_specification {
    cpu_credits = "unlimited"
  }

  provisioner "file" {
    source      = "../ansible/ansible.cfg"
    destination = "/var/tmp/ansible.cfg"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
    
  }

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

  #prepare /etc/profile
  provisioner "file" {
    source      = "../resource_pool_cli/resource_pool_profile"
    destination = "/var/tmp/resource_pool_profile"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
    
  }

  #prepare /home/ubuntu/.bashrc rpa append 
  provisioner "file" {
    source      = "../user_facing/rpa_bashrc_app"
    destination = "/var/tmp/rpa_bashrc_app"
    
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
 
  #append to profile
  provisioner "remote-exec" {
    inline = [
      "echo 'cat /var/tmp/resource_pool_profile >> /etc/profile' | sudo bash" #  >> /etc/profile"
    ]
    # "echo 'source /var/tmp/user_facing/1-setup-env.sh; source /var/tmp/user_facing/2-setup-mkdirs.sh; source /var/tmp/user_facing/3-setup-extractplaybooks.sh; source /var/tmp/user_facing/4a-setup-install.sh; sleep 30; source /var/tmp/user_facing/4b-setup-install.sh' >> /etc/profile sudo bash "
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

  #append to user bashrc 
  provisioner "remote-exec" {
    inline = [
      "echo 'cat /var/tmp/rpa_bashrc_app >> /home/ubuntu/.bashrc' | sudo bash" 
    ]
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      #self here should be equivalent to aws_instance.captain.public_dns, but terraform recommends using self
      host     = "${aws_instance.captain.public_ip}"
    }
  }
}

#Create a new resource, this time a t2.medium EC2 instance with 6 nodes
#TODO: rename server --> cluster (k8s or trad datacenter), more accurate
resource "aws_instance" "resource_server_medium" {
  ami           = "ami-01d9d5f6cecc31f85"
  instance_type = "t2.medium"
  count         = 2
  key_name      = "ajacobs-IAM-keypair"
  associate_public_ip_address = false # these aren't for the public
  
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
    Name = "resource_server_medium"
  }

  provisioner "file" {
    source      = "../user_facing"
    destination = "/var/tmp"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }

  ##securely provision secrets - only root users can see this
  provisioner "file" {
    source      = "../_donottrack/ajacobsdocid_access_token.txt"
    destination = "/var/tmp/doc_acc_tok"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }

  ##prepare /etc/profile
  provisioner "file" {
    source      = "../resource_pool_cli/resource_pool_profile"
    destination = "/var/tmp/resource_pool_profile"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }

  ##prepare /home/ubuntu/.bashrc rpa append 
  provisioner "file" {
    source      = "../user_facing/rpa_bashrc_app"
    destination = "/var/tmp/rpa_bashrc_app"
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }
  ##provisioner "local-exec" {
  ##  command = "echo hec2-3-84-41-174.compute-1.amazonaws.comey I am running on your machine"
  ##}
 
  ##append to profile
  provisioner "remote-exec" {
    inline = [
      "echo 'cat /var/tmp/resource_pool_profile >> /etc/profile' | sudo bash" #  >> /etc/profile"
    ]
    # "echo 'source /var/tmp/user_facing/1-setup-env.sh; source /var/tmp/user_facing/2-setup-mkdirs.sh; source /var/tmp/user_facing/3-setup-extractplaybooks.sh; source /var/tmp/user_facing/4a-setup-install.sh; sleep 30; source /var/tmp/user_facing/4b-setup-install.sh' >> /etc/profile sudo bash "
    # "echo 'hostname -b captain-node' | sudo bash ", #cute, but it broke networking... don't play with hostnames
    #  "echo '; source 4a-setup-install.sh; source 4b-setup-install.sh' | sudo bash "
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }

  ##append to user bashrc 
  provisioner "remote-exec" {
    inline = [
      "echo 'cat /var/tmp/rpa_bashrc_app >> /home/ubuntu/.bashrc' | sudo bash" 
    ]
    
    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = file("/home/ajacobs/Professional/Projects/InsightFellowship/AWS/ajacobs-IAM-keypair.pem")
      host     = "${self.public_ip}"
    }
  }
}

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


#######################
###### Output/Debug ###
#######################

#Print the captain's public id to the terminal after things like terraform apply or refresh
output "captain_host_details" {
  value = [
    "${aws_instance.captain.public_ip}",
    "${aws_instance.captain.private_ip}",
    "${aws_instance.captain.public_dns}",
    "${aws_eip_association.eip_captain_assoc}"
  ]
  #value = ["${aws_instance.captain.public_ip} ${aws_instance}"]
}

output "resource_server_medium_details" {
  value = [
    "${aws_instance.resource_server_medium.*.public_ip}",
    "${aws_instance.resource_server_medium.*.private_ip}"
  ]
}

output "aws_eip_rp_igw" {
  value = ["${aws_eip.rp_igw}"]
}

output "aws_eip_capt_public_igw" {
  value = ["${aws_eip.public_igw}"]
}
#
#output "resource_server_micro_public_ips" {
#  value = ["${aws_instance.resource_server_micro.*.public_ip}"]
#}
#output "igw_eip" {
#  value = ["${aws_eip_association.eip_assoc.*}"]
#}
