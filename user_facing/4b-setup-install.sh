#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# export read-only (by root) key, lock it down
cat ${DIR_ANSIBLE}/keys/id_rsa.pub >> /root/.ssh/authorized_keys
#chmod 400 ${DIR_ANSIBLE}/keys/*

# LET USER KNOW NEXT STEPS
echo "The resource_pool utility is now available at $ rpa_cli"
echo ""
echo "First time setup for admins: execute deploy-ansible-keys after configuring /etc/resource_pool/ansible/hosts and fetching IAM-keypair.pem "