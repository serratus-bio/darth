#### Assumptions:
## * AWS CLI installed & configured
## * sudo apt-get install make python2.7

#### Make configuration:

## Use Bash as default shell, and in strict mode:
SHELL := /bin/bash
.SHELLFLAGS = -ec

## If the parent env doesn't ste TMPDIR, do it ourselves:
TMPDIR ?= /tmp


## This makes all recipe lines execute within a shared shell process:
## https://www.gnu.org/software/make/manual/html_node/One-Shell.html#One-Shell
.ONESHELL:

## If a recipe contains an error, delete the target:
## https://www.gnu.org/software/make/manual/html_node/Special-Targets.html#Special-Targets
.DELETE_ON_ERROR:

## This is necessary to make sure that these intermediate files aren't clobbered:
.SECONDARY:


### Local definitions:

export PATH := $(PATH):$(CURDIR)/third-party/sratoolkit.2.10.5-ubuntu64/bin:$(CURDIR)/third-party/FragGeneScan1.31:$(CURDIR)/third-party/VIGOR4/vigor-4.1.20200430-122814-96585d9/bin:$(CURDIR)/third-party/vadr:$(CURDIR)/third-party/vadr/Bio-Easel/src/easel/miniapps

## VADR:
export VADRINSTALLDIR := $(HOME)/repos/darth/third-party/vadr
export VADRSCRIPTSDIR := $(VADRINSTALLDIR)/vadr
export VADRMODELDIR := $(VADRINSTALLDIR)/vadr-models
export VADRINFERNALDIR := $(VADRINSTALLDIR)/infernal/binaries
export VADREASELDIR := $(VADRINSTALLDIR)/infernal/binaries
export VADRHMMERDIR := $(VADRINSTALLDIR)/hmmer/binaries
export VADRBIOEASELDIR := $(VADRINSTALLDIR)/Bio-Easel
export VADRSEQUIPDIR := $(VADRINSTALLDIR)/sequip
export VADRBLASTDIR := $(VADRINSTALLDIR)/ncbi-blast/bin
export PERL5LIB := $(VADRSCRIPTSDIR):$(VADRSEQUIPDIR):$(VADRBIOEASELDIR)/blib/lib:$(VADRBIOEASELDIR)/blib/arch:$(PERL5LIB)
export PATH := $(VADRSCRIPTSDIR):$(PATH)

#### Targets:

### Software install:

pre-installs:
	mkdir -p third-party
	sudo apt-get install emboss samtools parallel bcftools tabix


# install-fraggenescan: pre-installs
# 	cd third-party
# 	wget "https://sourceforge.net/projects/fraggenescan/files/FragGeneScan1.31.tar.gz"
# 	tar xzf FragGeneScan1.31.tar.gz
# 	cd FragGeneScan1.31
# 	make clean
# 	make fgs

## I install it to /home/ubuntu/.miniconda3
install-miniconda:
	wget "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh"
	if [ `sha256sum Miniconda3-latest-Linux-x86_64.sh | cut -d' ' -f 1` == bb2e3cedd2e78a8bb6872ab3ab5b1266a90f8c7004a22d8dc2ea5effeb6a439a ]
	then
		chmod 700 Miniconda3-latest-Linux-x86_64.sh
		./Miniconda3-latest-Linux-x86_64.sh
	fi

#
# To activate this environment, use
#
#     $ conda activate snakemake
#
# To deactivate an active environment, use
#
#     $ conda deactivate

install-snakemake:
	conda install -c conda-forge mamba
	mamba create -c conda-forge -c bioconda -n snakemake snakemake


install-vadr: pre-installs install-vadr-deps 
	cd third-party
	git clone git@github.com:nawrockie/vadr.git
	cd vadr
	./vadr-install.sh linux

# export VADRINSTALLDIR="$HOME/repos/darth/third-party/vadr"
# export VADRSCRIPTSDIR="$VADRINSTALLDIR/vadr"
# export VADRMODELDIR="$VADRINSTALLDIR/vadr-models"
# export VADRINFERNALDIR="$VADRINSTALLDIR/infernal/binaries"
# export VADREASELDIR="$VADRINSTALLDIR/infernal/binaries"
# export VADRHMMERDIR="$VADRINSTALLDIR/hmmer/binaries"
# export VADRBIOEASELDIR="$VADRINSTALLDIR/Bio-Easel"
# export VADRSEQUIPDIR="$VADRINSTALLDIR/sequip"
# export VADRBLASTDIR="$VADRINSTALLDIR/ncbi-blast/bin"
# export PERL5LIB="$VADRSCRIPTSDIR":"$VADRSEQUIPDIR":"$VADRBIOEASELDIR/blib/lib":"$VADRBIOEASELDIR/blib/arch":"$PERL5LIB"
# export PATH="$VADRSCRIPTSDIR":"$PATH"


## The install script doesn't work all the way, and it doesn't
## clean up after itself if the install fails. Annoying!
vadr-clean:
	rm -r third-party/vadr


## Miniconda comes with SQLite3
install-vadr-deps:
	#sudo yum install -y autoconf.noarch
	sudo cpanm Inline
	sudo cpanm install Inline::C
	sudo cpanm install LWP::Simple
	sudo cpanm install LWP::Protocol::https


#conda install -y -c bioconda blast-legacy
#conda install -y -c bioconda clustalw

install-vigor4: pre-installs install-vigor4-deps
	cd third-party
	git clone git@github.com:JCVenterInstitute/VIGOR4.git
	cd VIGOR4
	mvn -DskipTests clean package
	unzip target/vigor-*.zip -d .




install-vigor4-deps: third-party/VIGOR_DB/README.md
	sudo yum install -y maven.noarch
	conda install -y -c bioconda exonerate


third-party/VIGOR_DB/README.md:
	cd third-party
	git clone git@github.com:JCVenterInstitute/VIGOR_DB.git


install-jbrowse: pre-installs
	cd third-party
	wget https://github.com/GMOD/jbrowse/releases/download/1.16.9-release/JBrowse-1.16.9-desktop-linux-x64.zip
	unzip JBrowse-1.16.9-desktop-linux-x64.zip


## Install Docker:
install-docker-prereqs:
	sudo apt-get update
	sudo apt-get -y install \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg-agent \
		software-properties-common
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

install-docker-repo-engine:
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$$(lsb_release -cs) \
		stable"
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io

### Install 

install-hhsuite: pre-installs
	cd third-party
	mkdir -p hhsuite-3.2.0
	cd hhsuite-3.2.0
	wget https://github.com/soedinglab/hh-suite/releases/download/v3.2.0/hhsuite-3.2.0-AVX2-Linux.tar.gz
	tar xvfz hhsuite-3.2.0-AVX2-Linux.tar.gz

install-fraggenescan: pre-installs
	cd third-party
	wget https://downloads.sourceforge.net/project/fraggenescan/FragGeneScan1.31.tar.gz
	tar xzf FragGeneScan1.31.tar.gz
	cd FragGeneScan1.31
	make clean
	make fgs

### Data staging:

pre-data-setup:
	mkdir -p data

get-wuhan-sars-cov-2-genome: pre-data-setup
	cd data
	wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz
	wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.gff.gz
	wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_protein.faa.gz
	wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_translated_cds.faa.gz
	gunzip *.gz

get-frankie: pre-data-setup
	cd data
	wget https://github.com/ababaian/serratus/wiki/assets/Fr4NK.fa

get-frankie-reads:
	cd data
	prefetch ERR2756788
	fastq-dump --split-e ERR2756788

get-bobbie: pre-data-setup
	cd data
	wget "http://data.cab.spbu.ru/index.php/s/Zkwb9SoCsqXTQEG/download?path=%2F&files=SRR9211913.tar.bz2" -O SRR9211913.tar.bz2
	tar xjf SRR9211913.tar.bz2

get-vadr-cov2-model: pre-data-setup
	cd data
	wget https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/coronaviridae/CURRENT/vadr-models-corona-1.1-1.tar.gz
	tar xzf vadr-models-corona-1.1-1.tar.gz

get-serratus-prots: pre-data-setup
	cd data
	wget https://serratus-public.s3.amazonaws.com/rce/protrefm_v2/protrefm_v2.fa

get-hhsuite-dbs: pre-data-setup
	cd data
	wget http://gwdu111.gwdg.de/~compbiol/uniclust/2020_03/UniRef30_2020_03_hhsuite.tar.gz
	tar xzf UniRef30_2020_03_hhsuite.tar.gz
	wget http://gwdu111.gwdg.de/~compbiol/uniclust/2020_03/uniref_mapping.tsv.gz

get-rfam-cov-utrs: pre-data-setup
	cd data
	wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.2/covid-19/coronavirus.clanin
	wget ftp://ftp.ebi.ac.uk/pub/databases/Rfam/14.2/covid-19/coronavirus.cm
	cmpress coronavirus.cm

get-cov3ma: pre-data-setup
	cd data
	aws s3 cp s3://serratus-public/seq/cov3ma/cov3ma.fa .
	esl-sfetch --index cov3ma.fa


### Docker Automation
docker-build:
	sudo docker build -t taltman/darth:maul .

docker-run:
	sudo docker run -it --rm -v $(CURDIR):/input -v $(CURDIR)/out:/output taltman/darth:maul bash 

docker-deploy:
	sudo docker login
	sudo docker push taltman/darth:maul

### Tests:

test-docker-frankie:
	cp data/Fr4NK.fa out/
	sudo docker run -it --rm -m 13GB -v $(CURDIR)/out:/output taltman/darth:test \
		darth.sh \
			ERR2756788 \
			/output/Fr4NK.fa \
			/output/ERR2756788.fastq.gz \
			/root/data \
			/output \
			2

test-sample:
	mkdir -p test/test-sample/
	cd test/test-sample
	aws s3 cp s3://serratus-public/assemblies/contigs/SRR9156994.coronaspades.gene_clusters.checkv_filtered.fa .
	cd ..
	sudo docker run -it --rm -m 13GB -v $$PWD/test-sample:/output taltman/darth:test \
		darth.sh \
			SRR9156994 \
			/output/SRR9156994.coronaspades.gene_clusters.checkv_filtered.fa \
			none \
			/root/data \
			/output \
			2


## Not in file: NC_046965.1
test-taxon-prot-gen:
	mkdir -p test/taxon-prots
	cd test/taxon-prots
	for acc in AY394999.1
	do
		echo "Processing genome $$acc:"
		mkdir -p $$acc
		pushd $$acc
		if esl-sfetch $(CURDIR)/data/cov3ma.fa $$acc > $$acc.fa
		then
			sudo docker run -it --rm -m 13GB -v `pwd`:/output taltman/darth:maul \
				darth.sh \
					$$acc \
					/output/$$acc.fa \
					none \
					/root/data \
					/output \
					2
		fi
		popd
		echo "... complete!"
	done

test-assemblies:
	mkdir -p test/assemblies
	cd test/assemblies
	for acc in DRR220591 ##ERR2756788  ## SRR8617922 ##ERR4145311   SRR5447152 ## SRR8389793 
	do
		echo "Processing genome $$acc:"
		mkdir -p $$acc
		pushd $$acc
		if aws s3 cp s3://serratus-rayan/master_table_assemblies/$$acc.fa .
		then
			time sudo docker run -it --rm -m 13GB -v `pwd`:/output taltman/darth:maul \
				darth.sh \
					$$acc \
					/output/$$acc.fa \
					none \
					/root/data \
					/output \
					2
		fi
		popd
		echo "... complete!"
	done

test-assembly-canonicalization:
	mkdir -p test/canonicalization
	cd test/canonicalization
	for acc in ERR2756788 ERR4145311 SRR8617922 SRR8389793 SRR5447152
	do
		echo "Processing genome $$acc:"
		mkdir -p $$acc
		pushd $$acc
		if aws s3 cp s3://serratus-rayan/master_table_assemblies/$$acc.fa .
		then
			$(CURDIR)/src/canonicalize_contigs.sh $$PWD/$$acc.fa $$PWD $(CURDIR)/data
		fi
		popd
		echo "... complete!"
	done


sars-cov-2-pfam-annot:
	mkdir -p test/sars-cov-2-pfam
	cd test/sars-cov-2-pfam
	transeq -clean -frame 6 \
		-sequence $(CURDIR)/data/GCF_009858895.2_ASM985889v3_genomic.fna \
		-outseq sars-cov-2-trans.fasta
	hmmsearch --cut_ga \
		-A match-alignments.sto \
		--domtblout hmmsearch-matches.txt \
		$(CURDIR)/data/Pfam-A.SARS-CoV-2.hmm \
		sars-cov-2-trans.fasta \
		> hmmstdout.txt
	egrep -v "^#" hmmsearch-matches.txt \
		| awk -v OFS="\t" '{ print $$4, $$1, $$18, $$19 }' \
		| sort -k3,3n \
		| awk -v OFS="\t" '{ print NR, $$1}' \
		> $(CURDIR)/data/sars-cov-2-pfam-order.txt 

check-runs-missing-annots:
	mkdir -p test/missing-annots
	cd test/missing-annots
	for acc in AY395000.1 HQ850618.1 KC008600.1 KM609205.1 KR265759.1 KR822424.1 KX219798.1 KX236009.1 KX236011.1 KX252780.1 KX302862.1 KY983586.1 MG021451.1 MG428702.1 MK071620.1 MN535737.1 MN692789.1 MN794188.1 MT263013.1 
	do
		aws s3 cp s3://serratus-public/seq/cov5/annotations/$$acc.cov5_cg.fa.darth.tar.gz .
		tar xzf $$acc.cov5_cg.fa.darth.tar.gz
	done
	for acc in NC_034976 NC_046956
	do
		aws s3 cp s3://serratus-public/seq/cov5/annotations/$$acc.fa.toro5_cg.fa.darth.tar.gz .
		tar xzf $$acc.fa.toro5_cg.fa.darth.tar.gz
	done

annot-vigor4-wuhan-sarscov2:
	mkdir -p test/sarscov2
	cd test/sarscov2
	vigor4 -i ../../data/GCF_009858895.2_ASM985889v3_genomic.fna -o sarscov2 -d sarscov2

annot-vigor4-frankie:
	mkdir -p test/frankie
	cd test/frankie
	vigor4 -i ../../data/Fr4NK.fa -o frankie -d sarscov2

## Took about ~5 minutes
annot-vadr-sars-cov-2:
	mkdir -p test
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 64000 \
		--lowsimterm 2 \
		--lowsc 0.75 \
		--fstlowthr 0.0 \
		--alt_fail lowscore,fsthicnf,fstlocnf \
		data/GCF_009858895.2_ASM985889v3_genomic.fna \
		test/sars-cov-2-vadr

## Took about ~5 minutes
annot-vadr-frankie:
	mkdir -p test
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 64000 \
		data/Fr4NK_revcomp.fa \
		test/frankie-vadr

annot-vadr-bobbie:
	mkdir -p test
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 13000 \
		data/gene_clusters.fasta \
		test/bobbie

annot-vadr-bobbie-full:
	mkdir -p test
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 13000 \
		data/scaffolds.fasta \
		test/bobbie-full

## Took about 11 mintues
## (so, no parallelization by 
annot-vadr-frankie-sars-cov-2:
	mkdir -p test
	cat data/Fr4NK_revcomp.fa data/GCF_009858895.2_ASM985889v3_genomic.fna > /tmp/test.fa
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 64000 \
		/tmp/test.fa \
		test/frankie-sars-cov-2-vadr

annotate-assemblies:
	cat data/catA-v2.txt \
        | time parallel \
		--jobs 1 \
		-N 1 \
		--timeout 900 \
		--joblog annot-jobs.txt \
		--retries 3 \
		--progress \
		--eta \
		--tag \
		--tmpdir /run/user/1000 \
		src/palpatine.sh



### Variant analysis:

## megablast: 2m26s
## blastn: 

eval-blastn_vdb-mapping:
	cd /dev/shm/
	mkdir -p blastn-map
	cd blastn-map	
	wget https://github.com/ababaian/serratus/wiki/assets/Fr4NK.fa
	revseq -sequence Fr4NK.fa -outseq Fr4NK_revcomp.fa
	samtools faidx Fr4NK_revcomp.fa
	#wget -r https://sra-download.ncbi.nlm.nih.gov/traces/era23/ERR/ERR2756/ERR2756788
	#cd sra-download.ncbi.nlm.nih.gov/traces/era23/ERR/ERR2756
	time blastn_vdb \
		-db "ERR2756788" \
		-query Fr4NK_revcomp.fa \
		-evalue .001 \
		-num_threads `nproc` \
		-outfmt 17 \
		-task megablast \
		-max_target_seqs 100000 \
		| sed 's/Query_1/Bat/' \
		| samtools view -S -b \
		| samtools sort \
		> test-megablast-sorted.bam
	samtools index test-megablast-sorted.bam
	time blastn_vdb \
		-db "ERR2756788" \
		-query Fr4NK_revcomp.fa \
		-evalue .001 \
		-num_threads `nproc` \
		-outfmt 17 \
		-task blastn \
		-max_target_seqs 100000 \
		| sed 's/Query_1/Bat/' \
		| samtools view -S -b \
		| samtools sort \
		> test-blastn-sorted.bam

## using default -> 7892 hard clipping
## using 5/-4/8/6 -> 7323 hard clipping
## using 1/-1/0/2 -> 
eval-blastn_vdb-variant-calling:
	cd /dev/shm/blastn-map
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/503/155/GCF_001503155.1_ViralProj307859/GCF_001503155.1_ViralProj307859_genomic.fna.gz
	gunzip GCF_001503155.1_ViralProj307859_genomic.fna.gz
	prefetch -p "ERR2756788"
	time blastn_vdb \
		-db "ERR2756788" \
		-query GCF_001503155.1_ViralProj307859_genomic.fna \
		-evalue 10 \
		-num_threads `nproc` \
		-outfmt "17 SQ" \
		-task blastn \
		-gapopen 8 \
		-gapextend 6 \
		-penalty -4 \
		-reward 5 \
		-max_target_seqs 100000 \
		| sed 's/Query_1/NC_028811.1/' \
		| samtools view -S -b \
		| samtools calmd -u - GCF_001503155.1_ViralProj307859_genomic.fna \
		| samtools sort \
		> frank-NC_028811-variants-sorted.bam 
	samtools index frank-NC_028811-variants-sorted.bam

## Interestingly, it takes 9 minutes to index just *half* of the FASTA'ized reads for ERR2756788
## Seems that blastn_vdb uses just 20-30 seconds to do the same!
## 
reproduce-blast-bug:
	awk '(NR%4)==1 { print ">" $2; getline; print }' /tmp/ERR2756788_1.fastq > /tmp/ERR2756788_1.fasta
	time makeblastdb -in /tmp/ERR2756788_1.fasta -dbtype nucl -out /tmp/ERR2756788_1
	time blastn \
		-db /tmp/ERR2756788_1 \
		-query Fr4NK_revcomp.fa \
		-evalue 10 \
		-num_threads `nproc` \
		-outfmt "17 SQ" \
		-task blastn \
		-gapopen 8 \
		-gapextend 6 \
		-penalty -4 \
		-reward 5 \
		-max_target_seqs 100000 \
		> blast-bug.sam

## Need to find hard clipped alignments, record the hits, the hard-clip numbers,
## and then search the FASTQ file to find the sequence & 
soft-clip-to-hard-clip:
	samtools view frank-NC_028811-variants-sorted.bam \
		| awk -F"\t" '{split($$1, vdb_coord, "."); print vdb_coord[2]}' \
		| sort | uniq \
		| parallel -X ~/repos/darth/src/vdb-dump-parallel.sh \
		> vdb-read-data.tsv
	export LC_ALL=C
	awk -F"\t" -v OFS="\t" \
		'function revcomp(str,   new_seq, i) {
			new_seq = "";
		 	for(i=length(str);i>0; i--)
				new_seq = new_seq comp[substr(str,i,1)];
			return new_seq;
		}
		function rev(str,   new_seq, i) {
			new_seq = "";
			for(i=length(str);i>0; i--)
				new_seq = new_seq substr(str,i,1);
			return new_seq;
		}
		BEGIN{ comp["A"] = "T"; comp["T"] = "A"; comp["G"] = "C"; comp["C"] = "G"; comp["N"] = "N"; }
		NR==FNR { 
		   vdb_stats[$$1][0] = "";
		   split($$0,vdb_stats[$$1]); 
		   next; }
		 /^@/ { print; next}
		 { split($$1, vdb_coord, ".");
		   spot_id = vdb_coord[2]
		   split(vdb_stats[spot_id][3],start_coords,", ");
		   num_scores = split(vdb_stats[spot_id][5],q_scores,", ");
		   q_str = "";		
		   gsub(/H/,"S",$$6);
		   if( vdb_coord[3] == "1" ) {
			$$10 = substr(vdb_stats[spot_id][4],1,start_coords[2]);			
			for(i=start_coords[1]+1;i<=start_coords[2];i++)
				q_str = q_str sprintf("%c", 33+q_scores[i]);
			$$11 = q_str;
		   }
		   else {
			$$10 = substr(vdb_stats[spot_id][4],start_coords[2]+1);
			for(i=start_coords[2]+1;i<=length(q_scores);i++)
				q_str = q_str sprintf("%c", 33+q_scores[i]);
			$$11 = q_str;
		   }
		   if ( $$2 == "16" ) {
			$$10 = revcomp($$10);
			$$11 = rev($$11);
		   }		
		   print;
		 }' \
	vdb-read-data.tsv \
	<(samtools view -h frank-NC_028811-variants-sorted.bam) \
	| samtools view -S -b \
	| samtools sort \
	> frankie-NC_028811-variants-softclip-sorted.bam
	samtools index frankie-NC_028811-variants-softclip-sorted.bam

variant-calling:
	bcftools mpileup -Ou \
		-f GCF_001503155.1_ViralProj307859_genomic.fna \
		frankie-NC_028811-variants-softclip-sorted.bam \
		| bcftools call -mv --ploidy 1 -Ob -o calls.bcf
	bcftools view calls.bcf > calls.vcf
	bgzip calls.vcf 
	tabix -p vcf calls.vcf.gz 

bowtie2-divergent-align:
	cd /dev/shm/blastn-map
	prefetch -p "ERR2756788"
	cd /tmp
	fastq-dump --split-e "ERR2756788"
	cd /dev/shm/blastn-map
	time bowtie2 --very-sensitive-local -x /dev/shm/blastn-map/NC_028811 -U /tmp/ERR2756788.fastq.gz -S > /dev/shm/blastn-map/bt2-align-very-sensitive-local.sam

bowtie2-self-align:
	cd /dev/shm/blastn-map
	time bowtie2 --very-sensitive-local -x /dev/shm/blastn-map/Fr4NK_revcomp -U /tmp/ERR2756788.fastq.gz \
	| samtools view -S -b \
	| samtools sort \
	> /tmp/bt2-self-align-very-sensitive-local-sorted.bam

#### NCBI submission preparation:

set-up-Fr4NK:
	mkdir -p test/Fr4NK-submission-test
	cd test/Fr4NK-submission-test
	aws s3 cp s3://serratus-public/assemblies/contigs/ERR2756788.coronaspades.gene_clusters.checkv_filtered.fa .
#### Utils
env:
	env

## Use lsblk to find a suitable ephemeral drive to use, then call it like:
## SWAP_DEVICE=/dev/nvme1n1 SWAP_SIZE=400G make set-up-swap
set-up-swap:
	sudo mkdir -p /media/ephemeral
	sudo mkfs.ext4 $(SWAP_DEVICE)
	sudo mount $(SWAP_DEVICE) /media/ephemeral
	sudo fallocate -l $(SWAP_SIZE) /media/ephemeral/swapfile
	sudo chmod 600 /media/ephemeral/swapfile
	sudo mkswap /media/ephemeral/swapfile
	sudo swapon /media/ephemeral/swapfile
