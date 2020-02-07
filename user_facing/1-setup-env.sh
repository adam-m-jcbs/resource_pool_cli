#!/bin/bash

# `1-setup-env.sh` serves to prepare the user environment

# SET UP DIRECTORY STRUCTURE AND PULL IN ANSIBLE INITIAL SETUP 
DIR_RESOURCE_POOL="/etc/resource_pool"
DIR_ANSIBLE="${DIR_RESOURCE_POOL}/ansible"
DIR_ANSIBLE_PLAYBOOKS="${DIR_ANSIBLE}/playbooks"
DIR_POOL_TEMPLATE="${DIR_ANSIBLE}/pool_template"
#TODO: would be better to not hard-code the GH url, if possible.  In my
#    experience working with raw files from GH is fragile and should be avoided.
#    any data a user pulls (wgets, in this case) should be available from a dedicated host and managed securely
GITRAW_BASE_URL="https://raw.githubusercontent.com/adam-m-jcbs/resource_pool_cli/master" 
URL_ANSIBLE_PLAYBOOKS="${GITRAW_BASE_URL}/ansible/playbooks"
URL_POOL_TEMPLATE="${GITRAW_BASE_URL}/ansible/pool_template"
URL_FLEET="${GITRAW_BASE_URL}/ansible/pools/fleet"
DOCKER_USER="ajacobsdocid"
DOCKER_IMG="${DOCKER_USER}/resource_pool_cli:latest"