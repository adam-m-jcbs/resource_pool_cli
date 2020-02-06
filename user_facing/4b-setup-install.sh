#!/bin/bash

# `4-setup-install.sh` serves to install our applications onto the infrastructure and expose functionality to end-customers
# 

# export read-only (by root) key, lock it down
chmod 400 ${DIR_ANSIBLE}/keys/*
cat ${DIR_ANSIBLE}/keys/id_rsa.pub >> /root/.ssh/authorized_keys