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
	--keep \
	transeq/canonical.fna \
	$output_dir

    ## if VADR crashes, we re-run with the --skip_pv option:
    ### https://github.com/nawrockie/vadr/issues/21
    
}

output_dir="$output_parent_dir/$accession"

## Canonicalize the assembly contigs:
canonicalize_contigs.sh $genome_path $output_parent_dir $data_dir

## Try running VADR:
run_vadr

# ## This is an ugly hack. Try to use VADR's install of blastn to just search RdRP gene, and use coordinates to figure out the orientation:
# ## This will NOT work! Need to stop punting and align to closest genome.
# if egrep REVCOMPLEM $output_dir/$accession.vadr.alc
# then
#     new_genome_path="$output_parent_dir/${accession}_revcomp.fna"
#     revseq -sequence $genome_path -outseq $new_genome_path
#     genome_path="$new_genome_path"
#     rm -r $output_dir 
#     run_vadr
# else
#     cp $genome_path $output_parent_dir/${accession}.fna
#     genome_path="$output_parent_dir/${accession}.fna"
# fi


## Annotate ORF1ab with Pfam domains:
mkdir -p $output_parent_dir/pfam
pushd $output_parent_dir/pfam > /dev/null

transeq -clean -frame F \
	-sequence $output_dir/*.CDS.1.fa \
	-outseq orf1ab_3-frame-translated.fasta

hmmsearch --cut_ga \
	  -A match-alignments.sto \
	  --domtblout hmmsearch-matches.txt \
	  $data_dir/Pfam-A.SARS-CoV-2.hmm \
	  orf1ab_3-frame-translated.fasta \
	  > hmmsearch-out.txt

esl-sfetch --index orf1ab_3-frame-translated.fasta

grep -v "^#" hmmsearch-matches.txt \
    | awk '{ print $4"/"$20"-"$21, $20, $21, $1}' \
    | esl-sfetch -Cf orf1ab_3-frame-translated.fasta - \
		 > orf1ab_domains.fasta

## Pull out the alignments:
awk 'NR==FNR && !/^#/ { pfam[($1 "/" $18 "-" $19)] = $4; next }
     /^\/\/$/         { print ">" pfam[id]; print line; line=""; next }
     !/^#/ && !/^$/   { id = $1; line=line $2; next }' \
	 hmmsearch-matches.txt \
	 match-alignments.sto \
	 > alignments.fasta

popd > /dev/null

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
	    > $accession.vadr.gff


## Generate alternate gene calls:
mkdir -p $output_parent_dir/FragGeneScan
pushd $output_parent_dir/FragGeneScan > /dev/null
run_FragGeneScan.pl -genome=$genome_path \
		    -out=gene-calls \
		    -complete=1 \
		    -train=complete \
		    -thread=$num_cpus
popd > /dev/null

## Scan genome for UTRs:
mkdir -p $output_parent_dir/UTRs
pushd $output_parent_dir/UTRs > /dev/null
genome_length="`egrep -v "^>" $genome_path | tr -d '\n' | wc | awk '{print $3}'`"
cm_db_size="`awk -v genome_length=$genome_length 'BEGIN{print genome_length*2/1000000}'`"
cmscan \
    -Z $cm_db_size \
    --cut_ga \
    --nohmmonly \
    --tblout cmscan-utrs.tblout \
    --fmt 2 \
    --clanin $data_dir/coronavirus.clanin \
    $data_dir/coronavirus.cm \
    $genome_path \
    > cmscan-utrs_stdout.txt
popd > /dev/null


### Read Analysis:
mkdir -p $output_parent_dir/read-analysis
pushd $output_parent_dir/read-analysis > /dev/null


## Self-align:

if [ "$reads_path" != "none" ]
then

	bowtie2-build $genome_path self_align
	bowtie2 --very-sensitive-local -x self_align -U $reads_path \
	    | samtools view -S -b \
	    | samtools sort \
		       > self-align-sorted.bam
	
	## Generate variant data:
	bcftools mpileup -Ou \
		 -f $genome_path \
		 self-align-sorted.bam \
	    | bcftools call -mv --ploidy 1 -Ob -o calls.bcf


## Generate convenience files for genome browsers like IGV and JBrowse:

	samtools index self-align-sorted.bam
	bcftools view calls.bcf > calls.vcf
	bgzip calls.vcf 
	tabix -p vcf calls.vcf.gz 
	samtools faidx $genome_path
fi

popd > /dev/null
