# Quick start

This is how to quick start this project.  This guide is evolving and may be
missing some important details.  It is mostly appropriate for quickstarting
after you're able to successfully execute a `terraform apply` in the
`/terraform` directory.

## Get things going, verify

If infrastructure is not active, I recommend bringing it up with
```
$ terraform init    # This will likely be redundant, but terraform is good at being idempotent and this does need to be done at least once
$ terraform refresh # Make sure terraform is up-to-date with the remote state
$ terraform plan    # Skim the output, make sure it's what you expect
$ terraform apply   # Your infrastructure should be spinning up now
```

For a project of this scope, I recommend verifying the infrastructure is up and
running as expected in an outside channel.  For example, you can verify
terraform's state matches the actual running infra by checking the AWS console.
I tend to use the AWS console app for this.  If not deploying on AWS, your
provider should have similar functionality available, and over time you want to
build your own monitoring and logging suited to your production.  

## Execute basic functionality

Now that your infra is up, we can utilize the basic functionality of `resource_pool_cli`.

First, ssh into the AWS captain instance (essentially, the master node in this design).  For details on connecting to a running AWS instance, these are useful references:
[establish conditions for connecting](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/connection-prereqs.html)
Check security groups, get public DNS, etc...

[actually connecting](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html)
ssh with the following incantation once you're setup:
```
ssh -i /full/path/to/IAM-keypair.pem default-ami-user@<instance public DNS>
```

Note, this is for AWS.  Consult other providers' documentation if you're not using AWS.

Now we can execute the original MVP's demo, found [here](https://youtu.be/WlnvPHdo3xs).

```
#Get setup.sh bootstrap
ubuntu@ip$ cd /var/tmp
ubuntu@ip$ wget https://raw.githubusercontent.com/glaracuente/resource_pool_cli/develop/user_facing/setup.sh

#Execute it
#This serves to:
#    - 
#    - 
#    - 
ubuntu@ip$ sudo bash setup.sh
```

```
#Creating and viewing pools

#simple list
ubuntu@ip$ sudo ./resource_pool.sh list

#make front end
ubuntu@ip$ sudo ./resource_pool.sh create frontend -c 5 -m 9

#make hackathon 
ubuntu@ip$ sudo ./resource_pool.sh create hackathon -c 3 -m 5

#make sure they're there
ubuntu@ip$ sudo ./resource_pool.sh list

#get mean, kill'em
ubuntu@ip$ sudo ./resource_pool.sh destroy hackathon

#confirm kill
ubuntu@ip$ sudo ./resource_pool.sh list

#if possible open up k8s dashboard

#observe the resize
ubuntu@ip$ sudo ./resource_pool.sh resize -c 8  list

```

#Docs to be orged later

## Kubernetes Deployment

Here we sketch out the essentials of the k8s deployment.

### My users
The first thing to understand is the users of this software.  They are technical developers that prefer to ssh into a machine and work from there.  Most of their workflows are organized around this principle.  While they are very technically savvy, they are not experts in cloud-native technology.  I have made the choice here to accomodate existing workflows.

Thus, the job of our k8s deployment here is: give our developers access to the features they want from cloud-native technology without them having to ever understand it or directly interact with it.  Rather, they use familiar commands in a familiar environment to achieve the same things they're doing in on-prem systems.

I achieve this with the `resource_pool_cli` API.

Now that you know this, you'll understand part of my motivation for deploying k8s in the way I'm about to describe.

If you `ssh` into my infra, you will find no `kubectl` or similar exposed.  No one working in this infra should have to think about k8s, docker, ansible, etc.  Perhaps in the future, but for now - no.

### How k8s is deployed
Rather, my k8s deployment is composed largely through a set of Ansible playbooks.  I will sketch that out here.

You do a `terraform apply` on my infra.  How is k8s stood up?



