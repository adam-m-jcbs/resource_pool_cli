#!/bin/bash

# `3-setup-extractplaybooks.sh` serves to pull in ansible playbooks that aid in building the infrastructure
#   

# PULL IN ANSIBLE INITIAL SETUP 
for playbook in drain reset install_k8s setup_master setup_k8s_dashboard; do
    wget "${URL_ANSIBLE_PLAYBOOKS}/${playbook}.yml" -O "${DIR_ANSIBLE_PLAYBOOKS}/${playbook}.yml"
done

for template_file in join masters workers; do
    wget "${URL_POOL_TEMPLATE}/${template_file}.yml" -O "${DIR_POOL_TEMPLATE}/${template_file}.yml"
done

wget "${URL_FLEET}/hosts" -O "${DIR_ANSIBLE}/pools/fleet/hosts"