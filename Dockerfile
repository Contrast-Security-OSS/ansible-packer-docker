FROM alpine:3.6

RUN \
  apk add --update-cache \
    docker \
    openssh-client \
    git \
    python-dev \
    python \
    py-yaml \
    py-jinja2 \
    py-crypto \
    py-boto \
    py-futures \
    py-pip \
    py-boto \
    curl  \
    jq \
    bind-tools && \
  rm -rf /var/cache/apk/*

RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN \
  apk add --update-cache \
    aws-cli \
    py-s3transfer \
    py-boto3 && \
  rm -rf /var/cache/apk/*

ENV TERRAFORM_VERSION=0.11.10
RUN apk add --update git curl openssh && \
    curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN \
  pip install --upgrade \
    boto3 \
    botocore

RUN \
  mkdir /ansible && \
  curl -fsSL https://releases.ansible.com/ansible/ansible-2.4.3.0.tar.gz -o ansible.tar.gz && \
  tar -xzf ansible.tar.gz -C ansible --strip-components 1 && \
  rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging


RUN \
  curl -fsSL https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip -o packer.zip && \
  unzip packer.zip -d /usr/bin/ && \
  rm -rf packer.zip


ENV \
  ANSIBLE_GATHERING=smart \
  ANSIBLE_HOST_KEY_CHECKING=False \
  ANSIBLE_RETRY_FILES_ENABLED=False \
  ANSIBLE_SSH_PIPELINING=True \
  PATH=/ansible/bin:$PATH \
  PYTHONPATH=/ansible/lib

ENTRYPOINT ["packer"]
