FROM python:3.8-alpine
ENV INSPEC_VERSION=4.17.14
ENV TERRAFORM_VERSION=0.13.2
ENV ANSIBLE_VERSION=2.8.19
ENV PACKER_VERSION=1.7.0

RUN \
  apk add --update-cache \
  docker \
  openssh-client \
  git \
  bash \
  curl  \
  cargo \
  g++ \
  gcc \
  jq \
  libxml2-dev \
  libffi-dev \
  openssl-dev \
  musl-dev \
  make \
  rust \
  unzip \
  wget && \
  rm -rf /var/cache/apk/* && \
  ln -s /usr/bin/python3 /usr/bin/python

# Ruby -> Inspec
RUN apk --no-cache add \
  ruby-dev \
  ruby-rdoc \
  ruby-bundler \
  ruby-json \
  ruby-bundler

RUN gem install bigdecimal && \
    gem install --no-document --version ${INSPEC_VERSION} inspec && \
    gem install --no-document --version ${INSPEC_VERSION} inspec-bin && \
    inspec detect --chef-license=accept-silent

# Terraform
RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Ansible
RUN \
  pip install --upgrade \
  pip \
  boto3 \
  botocore \
  awscli
RUN pip install ansible==${ANSIBLE_VERSION}

# Packer
RUN \
  curl -fsSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip -o packer.zip && \
  unzip packer.zip -d /usr/bin/ && \
  rm -rf packer.zip

ENV \
  ANSIBLE_GATHERING=smart \
  ANSIBLE_HOST_KEY_CHECKING=False \
  ANSIBLE_RETRY_FILES_ENABLED=False \
  ANSIBLE_SSH_PIPELINING=True \
  PATH=/ansible/bin:$PATH \
  PYTHONPATH=/ansible/lib
