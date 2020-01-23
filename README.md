__Resource Pool CLI__ by Adam Jacobs

## Project Summary:

`resource_pool_cli` is a tool originally written by developer Gerardo Laracuente (@glaracuente) while he was at Insight Data Science.
I have forked and adapted it here with permission.

`resource_pool_cli` provides a command-line interface that leverages a tool
written in Python for automatically creating, resizing, and destroying
Kubernetes clusters on in-house hardware. It regards these clusters as resource
pools that can be described in terms of cores and memory.  The use-case is
ramping up deployment of existing software on modern, cloud-aware platforms
while still being able to keep the code in production without completely
refactoring to be cloud-native or robustly containerized.

This fork builds out high availability and self-healing, enabling exploration
and prototyping of cloud-aware features as well as some initial benefits of a robust
DevOps platform:
- thing 1
- thing 2
 
## Why Resource Pool CLI?:

Many institutions are not running in the cloud using modern deployment
infrastructures.  The reasons why are unique to each institution, but common
reasons include: regulatory restrictions, the costs of robustly (securely!)
refactoring existing production codebases to be cloud-native without any
degradation in service, or the applications deployed utilize either specialized
hardware that's not well-supported _or_ relies on bare-metal, low-level access
to hardware that is difficult to target on major cloud platforms.

Some of these institutions will get a net monetary benefit from ramping up and
investing in developing cloud-native technologies, while others will get all
the value they need by continuing to run their applications as-is while
leveraging some of the benefits from technology that has emerged from the cloud: very
cheap, fast deployment - in production -; decoupling development infrastructure
from applications, enabling powerful monitoring and metrics that yield
actionable insight; and letting everyone in the institution focus on what
they're best at.

`resource_pool_cli` enables institutions in this position to start iterating on
solutions immediately, gaining insight into how they can leverage emerging
technology and what the cost-benefit analysis will look like.

## What's going on under the hood?:

Python CLI > Ansible > Servers = Kubernetes Clusters

The CLI is written in Python, but is powered by Ansible. Ansible playbooks contain the instructions to create new kubernetes clusters, add nodes, drain and delete nodes, etc. 

<p align="center">
<img src= img/arch.png width="700" height="400">
</p>

In the top half of the archtecture diagram, I show what this would look like in the real world. The user would just need to have one server running docker. After running one simple bash script, everything will be set up for them. This server runs the CLI alongside Ansible inside of a docker container. 

The bottom half shows what was used for development, and you can try this out yourself. I spun up mock "data centers" in AWS. These are just EC2 instances running Ubuntu 16.04, in the same VPC. I run the setup.sh script on one of them, and then use this instance to create k8s clusters out of the others. 


## Demo:   

[![Resource Pool CLI](http://img.youtube.com/vi/WlnvPHdo3xs/0.jpg)](http://www.youtube.com/watch?v=WlnvPHdo3xs "Resource Pool CLI")

Want to try it out? 
- All you need is the __setup.sh__ file from the __user_facing__ directory. 
- The server for running the CLI needs to have docker installed before running the setup script. 
- This entire project has only been tested on Ubuntu 16.04. 


## Future Work:

__Auto Healing__ - A scheduler needs to keep track of the desired resource counts for each pool. When a server goes down, the scheduler should notice the decrease in resources, and automatically replace the server and notify an admin, create a ticket, etc. 

__HA of Masters__ - The master of each cluster is currently a point of failure. The master should be a set of servers set up for HA.

__Load Balancer__ - Since this should be able to run on baremetal, "Metal LB" needs to be added to the cluster in order to expose services properly. NodePort is currently used, but this is not a production ready method. 
