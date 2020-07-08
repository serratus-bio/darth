#!/bin/bash -e

#### darth: Run VADR on Serratus assemblies.

accession="$1"
genome_path="$2"
reads_path="$3"
data_dir="$4"
output_parent_dir="$5"
num_cpus="$6"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"

export PATH=$PATH:$DIR

##accession="`awk 'NR==1 { gsub(/^>/,""); print \$1 }' $genome_path`"

function run_vadr() {

    v-annotate.pl \
	--mdir $data_dir/vadr-models-corona-1.1-1 \
	--mkey corona \
	--mxsize 64000 \
	-f \
	$genome_path \
	$output_dir

}

output_dir="$output_parent_dir/$accession"

## Try running VADR:
run_vadr

## This is an ugly hack. Try to use VADR's install of blastn to just search RdRP gene, and use coordinates to figure out the orientation:

if egrep REVCOMPLEM $output_dir/$output_name.vadr.alc
then
    new_genome_path="$output_dir/${accession}_revcomp.fna"
    revseq -sequence $genome_path -outseq $new_genome_path
    genome_path="$new_genome_path"
    rm -r $output_dir 
    run_vadr
else
    cp $genome_path $output_dir/`basename $genome_path`
    genome_path="$output_dir/`basename $genome_path`"
fi

## Generate alternate gene calls:
run_FragGeneScan.pl -genome=$genome_path \
		    -out=$output_dir/gene-calls \
		    -complete=1 \
		    -train=complete \
		    -thread=$num_cpus

## Scan genome for UTRs:
genome_length="`egrep -v "^>" $genome_path | tr -d '\n' | wc | awk '{print $3}'`"
cm_db_size="`awk -v genome_length=$genome_length 'BEGIN{print genome_length*2/1000000}'`"
cmscan \
    -Z $cm_db_size \
    --cut_ga \
    --rfam \
    --nohmmonly \
    --tblout $output_dir/cmscan-utrs.tblout \
    --fmt 2 \
    --clanin $data_dir/coronavirus.clanin \
    $data_dir/coronavirus.cm \
    $genome_path \
    > $output_dir/cmscan-utrs_stdout.txt


## Self-align:

bowtie2-build $genome_path $data_dir/self_align
bowtie2 --very-sensitive-local -x $data_dir/self_align -U $reads_path \
    | samtools view -S -b \
    | samtools sort \
	       > $output_dir/self-align-sorted.bam

## Generate variant data:
bcftools mpileup -Ou \
	 -f $genome_path \
	 $output_dir/self-align-sorted.bam \
    | bcftools call -mv --ploidy 1 -Ob -o $output_dir/calls.bcf



### Generate convenience files for genome browsers like IGV and JBrowse:

## Convert VADR output to GFF

if [ -s $output_dir/$accession.vadr.pass.tbl ]
then
    tbl_file=$output_dir/$accession.vadr.pass.tbl
else
    tbl_file=$output_dir/$accession.vadr.fail.tbl
fi

tbl2gff.awk -v seqid="$accession" \
	    -v prog=vadr \
	    $tbl_file \
	    > $output_dir/$accession.vadr.gff

samtools index $output_dir/self-align-sorted.bam
bcftools view $output_dir/calls.bcf > $output_dir/calls.vcf
bgzip $output_dir/calls.vcf 
tabix -p vcf $output_dir/calls.vcf.gz 
samtools faidx $genome_path
