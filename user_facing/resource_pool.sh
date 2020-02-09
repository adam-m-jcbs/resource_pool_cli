#!/bin/bash

# TODO Figure out exactly what this is for.
# current guess: the cli is basically a wrapper around docker

RESOURCE_CLI_ARGS="$@"

if [[ $# -eq 0 ]] ; then
    RESOURCE_CLI_ARGS="-h"
fi

DIR_ANSIBLE="/etc/resource_pool/ansible/"

RESOURCE_CLI_ARGS_NOSPACE="$(echo -e "${RESOURCE_CLI_ARGS}" | tr -d '[:space:]')" 
if [ "${RESOURCE_CLI_ARGS_NOSPACE}" = "bash" ]; then
    #drop into an interactive shell withing the container env, good for admin
    docker run --entrypoint="" -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest bash
elif [ "${RESOURCE_CLI_ARGS_NOSPACE}" = "deploy-ansible-keys" ]; then
    #deploy auth keys to hosts, enabling ansible management
    #docker run --entrypoint="" -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest bash
    for cur_host in $(awk '{ for(i = 1; i <= NF; i++) { print $i; } }' /etc/resource_pool/ansible/hosts)
    do
        #echo 'scp -i ajacobs-IAM-keypair.pem /etc/resource_pool_cli/ansibe/keys/id_rsa.pub ubuntu@${host}:~' | sudo bash
        echo "scp -i ajacobs-IAM-keypair.pem /etc/resource_pool/ansible/keys/id_rsa.pub ubuntu@${cur_host}:~" | sudo bash
        echo "ssh -i ajacobs-IAM-keypair.pem ubuntu@${cur_host} cat id_rsa.pub >> /root/.ssh/authorized_keys" | sudo bash
    done


else
    #a nice docker wrapper around the python API exposed in resource_pool_cli.py
    docker run -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest ${RESOURCE_CLI_ARGS}
fi
#docker run -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest ${RESOURCE_CLI_ARGS}
#docker run --entrypoint="" -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest ${RESOURCE_CLI_ARGS}