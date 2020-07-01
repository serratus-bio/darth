FROM taltman/vadr:1.1

MAINTAINER Tomer Altman, Altman Analytics LLC

Workdir /root

### Install apt dependencies

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y emboss

