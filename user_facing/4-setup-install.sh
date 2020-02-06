#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# PULL THE RESOURCE_POOL DOCKER IMAGE
#    e.g. docker_userid/resource_pool:latest
docker pull ${DOCKER_IMG}

# GENERATE SSH KEYS THAT WILL BE USED BY ANSIBLE
docker run -it --entrypoint="" -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ${DOCKER_IMG} /usr/bin/ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
chmod 400 ${DIR_ANSIBLE}/keys/*

# FETCH THE RESOURCE POOL WRAPPER SCRIPT
wget ${GITRAW_BASE_URL}/user_facing/resource_pool.sh -O "${DIR_RESOURCE_POOL}/resource_pool.sh"
chmod 755 "${DIR_RESOURCE_POOL}/resource_pool.sh"

# LET USER KNOW NEXT STEPS
echo "The resource_pool utility is now available at /etc/resource_pool/resource_pool.sh. Before using, you should:"
echo ""
echo "1) Add the contents of /etc/resource_pool/ansible/keys/id_rsa.pub to /root/.ssh/authorized_keys on all servers you would like to use for this set of infrastructure."
echo ""
echo "2) Add the IP addresses of these servers to /etc/resource_pool/ansible/pools/fleet/hosts.yml"