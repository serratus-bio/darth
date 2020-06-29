#!/bin/bash -e

#### darth: Run VADR on Serratus assemblies.

genome_path="$1"
output_dir="$2"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

export PATH=$PATH:$DIR

accession="`awk 'NR==1 { gsub(/^>/,""); print \$1 }' $genome_path`"

function run_vadr() {

    v-annotate.pl \
	--mdir data/vadr-models-corona-1.1-1 \
	--mkey corona \
	--mxsize 64000 \
	-f \
	$genome_path \
	$output_dir

}

output_name="`basename $output_dir`"

## Try running VADR:
run_vadr

## This is an ugly hack. Try to use VADR's install of blastn to just search RdRP gene, and use coordinates to figure out the orientation:

if egrep REVCOMPLEM $output_dir/$output_name.vadr.alc
then
    new_genome_path="`dirname $genome_path`/${accession}_revcomp.fna"
    revseq -sequence $genome_path -outseq $new_genome_path
    genome_path="$new_genome_path"
    rm -r $output_dir 
    run_vadr
fi
   
## Convert output to GFF

if [ -s $output_dir/$output_name.vadr.pass.tbl ]
then
    tbl_file=$output_dir/$output_name.vadr.pass.tbl
else
    tbl_file=$output_dir/$output_name.vadr.fail.tbl
fi

tbl2gff.awk -v seqid="$accession" \
	    -v prog=vadr \
	    $tbl_file \
	    > $output_dir/$output_name.vadr.gff
