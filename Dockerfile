FROM alpine:3.6
ENV TERRAFORM_VERSION=0.12.8
ENV ANSIBLE_VERSION=2.8.5
ENV PACKER_VERSION=1.4.3

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
    ruby \
    ruby-io-console \
    build-base \
    ruby-dev \
    libxml2-dev \
    libffi-dev \
    bind-tools && \
  rm -rf /var/cache/apk/*

RUN gem install --no-document inspec && \
    gem install --no-document inspec-bin  && \
    apk del build-base

RUN \
  echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin && \
    rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip

RUN \
  pip install --upgrade \
    pip \
    boto3 \
    botocore \
    awscli

RUN \
  mkdir /ansible && \
  curl -fsSL https://releases.ansible.com/ansible/ansible-${ANSIBLE_VERSION}.tar.gz -o ansible.tar.gz && \
  tar -xzf ansible.tar.gz -C ansible --strip-components 1 && \
  rm -fr ansible.tar.gz /ansible/docs /ansible/examples /ansible/packaging


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
