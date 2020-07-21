#!/bin/bash

#### canonicalize_contigs.sh:
##
## Given a CoV assembly, figure out the correct ordering of the contigs,
## taking into account reverse complement as needed.
##
## Input:
## genome_path: absolute path to the genome
## output_parent_dir: output directory absolute path
## data_dir: Where to find the sars-cov-2-pfam-order.txt file
## 
## Output: directory with intermediate files, and "canonical.fna"
## as canonicalized output genome sequence file.

genome_path="$1"
output_parent_dir="$2"
data_dir="$3"

### Figure out the orientation of the contigs, and rearrange:
### At the same time, prodice output files for alignments:
mkdir -p $output_parent_dir/transeq
pushd $output_parent_dir/transeq > /dev/null

## Translate the full genome in all six frames:
transeq -clean -frame 6 \
	-sequence $genome_path \
	-outseq trans-6-frame.fasta

## Annotate all frames with Pfam:
hmmsearch --cut_ga \
	-A match-alignments.sto \
	--domtblout hmmsearch-matches.txt \
	$data_dir/Pfam-A.SARS-CoV-2.hmm \
	trans-6-frame.fasta \
	> hmmstdout.txt

## Convert the alignments into a better format for merging across samples:
awk 'NR==FNR && !/^#/ { pfam[($1 "/" $18 "-" $19)] = $4; next }
     /^\/\/$/         { print ">" pfam[id]; print line; line=""	; next }
     !/^#/ && !/^$/   { id = $1; line=line $2; next }' \
	 hmmsearch-matches.txt \
	 match-alignments.sto \
	 > alignments.fasta

## Convert domain model names to order, and then sort numerically:
awk -v OFS="\t" 'BEGIN{orig_FS=FS; FS="\t"} \
    NR==FNR{ domain_order[$2] = $1; next} \
    NR!=FNR && FNR==1 {FS=orig_FS} \
    !/^#/ && $4 in domain_order { num_fields=split($1,fields,"_"); \
    	       	  	       	 gsub(/_[123456]$/,"",$1); \
				 print domain_order[$4], $1, fields[num_fields] }' \
    $data_dir/sars-cov-2-pfam-order.txt \
    hmmsearch-matches.txt \
    | sort -n \
    | awk -v OFS="\t" \
	  '!contig_seen[$2]++ { contig_order[++num_contigs] = $2 } \
	  $3 < 4 { contig_orientation[$2]["F"]++} \
	  $3 >= 4 {contig_orientation[$2]["R"]++} \
	  END { for(i=1; i<=num_contigs; i++) { \
	      	    contig_name=contig_order[i]; \
		    print contig_name, \
		    	  ((contig_orientation[contig_name]["F"] > contig_orientation[contig_name]["R"])?"F":"R") } }' \
	  > contig_order.txt

## Separate the contigs, rev-comp contigs as needed, and recombine in order
awk '/^>/ { id=$1;  gsub(/^>/,"",id); file= id ".fna"} { print $0 > file }' $genome_path

[ -e canonical.fna ] && rm canonical.fna

while read seq strand
do
    if [ $strand = "F" ]
    then
	revseq -noreverse -nocomplement -notag \
	       -sequence $seq.fna \
	       -outseq $seq.pp.fna
	cat $seq.pp.fna >> canonical.fna
	rm $seq.pp.fna
    else
	revseq -sequence $seq.fna -outseq ${seq}_revcomp.fna
	cat ${seq}_revcomp.fna >> canonical.fna
	rm ${seq}_revcomp.fna
    fi
done < contig_order.txt

## In the pathological case where a contig doesn't have any domain matches,
## just stick them onto the end, unmodified:
for file in `ls *.fna | egrep -v canonical.fna`
do
    if ! egrep `basename $file .fna` contig_order.txt > /dev/null
    then
       echo $file > no-ordered-contigs.txt
	revseq -noreverse -nocomplement -notag \
	       -sequence $file \
	       -outseq $file.pp
	cat $file.pp >> canonical.fna
	rm $file.pp
    fi
done


popd > /dev/null
