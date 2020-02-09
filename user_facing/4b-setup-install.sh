#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# export read-only (by root) key, lock it down
cat ${DIR_ANSIBLE}/keys/id_rsa.pub >> /root/.ssh/authorized_keys
#chmod 400 ${DIR_ANSIBLE}/keys/*

# LET USER KNOW NEXT STEPS
echo "The resource_pool utility is now available at $ rpa_cli"
echo ""
echo "First time setup for admins:"
echo "     1) configure /etc/resource_pool_cli/ansible/hosts and fetch IAM-keypair.pem"
echo "     2) execute otb on each host"
echo "     3) execute deploy-ansible-keys after hosts are primed"