#Use alpine:3.7 as base image (note: 3.7 is no longer supported by Docker's official alpine image)
FROM alpine:3.7

#Set evnironment variable
ENV ANSIBLE_VERSION 2.8.0
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_SSH_PIPELINING True
ENV PYTHONPATH /ansible/lib
ENV PATH /ansible/bin:$PATH

ENV BUILD_PACKAGES \
  bash \
  curl \
  wget \
  tar \
  openssh-client \
  sshpass \
  git \
  python \
  python3 \
  py-boto \
  py-dateutil \
  py-httplib2 \
  py-jinja2 \
  py-paramiko \
  py-pip \
  py-yaml \
  ca-certificates

# Build on top of the base image
RUN set -x && \
    \
    echo "==> Adding build-dependencies..."  && \
    apk --update add --virtual build-dependencies \
      gcc \
      musl-dev \
      libffi-dev \
      openssl-dev \
      python-dev && \
    \
    echo "==> Upgrading apk and system..."  && \
    apk update && apk upgrade && \
    \
    echo "==> Adding Python runtime..."  && \
    apk add --no-cache ${BUILD_PACKAGES} && \
    pip install --upgrade pip && \
    pip install python-keyczar docker-py && \
    \
    echo "==> Installing Ansible..."  && \
    pip install ansible==${ANSIBLE_VERSION} && \
    mkdir -p /etc/ansible /ansible && \
    \
    echo "==> Cleaning up..."  && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    \
    echo "==> Adding resource_pool cli..."  && \
    pip3 install click prettytable && \
    mkdir /etc/resource_pool_cli/ && \
    wget https://raw.githubusercontent.com/adam-m-jcbs/resource_pool_cli/master/resource_pool_cli/resource_pool_cli.py \
    -O /etc/resource_pool_cli/resource_pool_cli.py && \
    wget https://raw.githubusercontent.com/adam-m-jcbs/resource_pool_cli/master/resource_pool_cli/pool_helpers.py \
    -O /etc/resource_pool_cli/pool_helpers.py && \
    chmod 755 /etc/resource_pool_cli/resource_pool_cli.py && \
    chmod 755 /etc/resource_pool_cli/pool_helpers.py


#Expose this image similar to how CLI's are exposed: as an entry point command that args can be appended to
ENTRYPOINT ["/etc/resource_pool_cli/resource_pool_cli.py"]
#TODO: add default command, like:
#   CMD ["arg1", "arg2"]
