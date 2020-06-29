#!/bin/bash -e

s3_genome="$1"
genome_name="`basename $s3_genome .fa`"

output_dir="$2"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
export PATH=$PATH:$DIR

aws s3 cp $s3_genome /dev/shm

# pushd /dev/shm > /dev/null

# wget https://serratus-public.s3.amazonaws.com/assemblies/contigs/$genome_name.fa

# popd > /dev/null

darth.sh /dev/shm/$genome_name.fa /dev/shm/$genome_name

pushd /dev/shm > /dev/null

tar czf $genome_name.tar.gz $genome_name

aws s3 cp $genome_name.tar.gz s3://serratus-taltman/annotations/$output_dir/

rm -r $genome_name.tar.gz $genome_name.fa
