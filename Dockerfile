FROM taltman/vadr:1.1

MAINTAINER Tomer Altman, Altman Analytics LLC

Workdir /root

### Install apt dependencies

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y wget emboss samtools parallel bcftools tabix make infernal bowtie2 

### Install third-party software:
RUN mkdir /root/third-party

## Install FragGeneScan:
RUN cd /root/third-party \
       && wget https://downloads.sourceforge.net/project/fraggenescan/FragGeneScan1.31.tar.gz \
       && tar xzf FragGeneScan1.31.tar.gz \
       && cd FragGeneScan1.31 \
       && make clean \
       && make fgs

### Load data dependencies:
RUN mkdir /root/data

## CM models for VADR:
RUN cd /root/data \
       && wget https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/coronaviridae/CURRENT/vadr-models-corona-1.1-1.tar.gz \
       && tar xzf vadr-models-corona-1.1-1.tar.gz

## CM models for CoV 5' and 3' UTRs:
RUN cd /root/data \
       && wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.2/covid-19/coronavirus.clanin \
       && wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.2/covid-19/coronavirus.cm \
       && cmpress coronavirus.cm


### Set up environment to ease running code from running container:

## Staging scripts:
COPY src/darth.sh /usr/local/bin/
COPY src/tbl2gff.awk /usr/local/bin/

## Set script permissions:
RUN chmod 755 /usr/local/bin/darth.sh

ENV PATH $PATH:/root/third-party/FragGeneScan1.31