#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# export read-only (by root) key, lock it down
chmod 400 ${DIR_ANSIBLE}/keys/*
cat ${DIR_ANSIBLE}/keys/id_rsa.pub >> /root/.ssh/authorized_keys

# LET USER KNOW NEXT STEPS
echo "The resource_pool utility is now available at /etc/resource_pool/resource_pool.sh. Before using, you should:"
echo ""
echo "2) Add the IP addresses of these servers to /etc/resource_pool/ansible/pools/fleet/hosts.yml"