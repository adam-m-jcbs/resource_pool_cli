#!/bin/bash

# TODO Figure out exactly what this is for.
# current guess: the cli is basically a wrapper around docker

RESOURCE_CLI_ARGS="$@"

if [[ $# -eq 0 ]] ; then
    RESOURCE_CLI_ARGS="-h"
fi

DIR_ANSIBLE="/etc/resource_pool/ansible/"

#docker run -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest ${RESOURCE_CLI_ARGS}
docker run --entrypoint="" -it -v ${DIR_ANSIBLE}:/etc/ansible/ -v ${DIR_ANSIBLE}/keys/:/root/.ssh/ ajacobsdocid/resource_pool_cli:latest ${RESOURCE_CLI_ARGS}