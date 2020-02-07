#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# PULL THE RESOURCE_POOL DOCKER IMAGE
#    e.g. docker_userid/resource_pool:latest
cat ../doc_acc_tok | docker login --username ajacobsdocid --password-stdin
rm ../doc_acc_tok
docker pull ${DOCKER_IMG}

# GENERATE SSH KEYS THAT WILL BE USED BY ANSIBLE
docker run -it --entrypoint="" -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ${DOCKER_IMG} /usr/bin/ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''

# FETCH THE RESOURCE POOL WRAPPER SCRIPT
wget ${GITRAW_BASE_URL}/user_facing/resource_pool.sh -O "${DIR_RESOURCE_POOL}/resource_pool.sh"
chmod 755 "${DIR_RESOURCE_POOL}/resource_pool.sh"