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

export PATH := $(PATH):$(CURDIR)/third-party/sratoolkit.2.10.5-ubuntu64/bin:$(CURDIR)/third-party/FragGeneScan1.31:$(CURDIR)/third-party/VIGOR4/vigor-4.1.20200430-122814-96585d9/bin:$(CURDIR)/third-party/vadr


#### Targets:

### Software install:

pre-installs:
	mkdir -p third-party
	sudo apt-get install emboss


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

# export VADRINSTALLDIR="/home/taltman/repos/darth/third-party/vadr"
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

get-vadr-cov2-model: pre-data-setup
	cd data
	wget https://ftp.ncbi.nlm.nih.gov/pub/nawrocki/vadr-models/coronaviridae/CURRENT/vadr-models-corona-1.1-1.tar.gz
	tar xzf vadr-models-corona-1.1-1.tar.gz

### Tests:

annot-vigor4-wuhan-sarscov2:
	mkdir -p test/sarscov2
	cd test/sarscov2
	vigor4 -i ../../data/GCF_009858895.2_ASM985889v3_genomic.fna -o sarscov2 -d sarscov2

annot-vigor4-frankie:
	mkdir -p test/frankie
	cd test/frankie
	vigor4 -i ../../data/Fr4NK.fa -o frankie -d sarscov2

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

annot-vadr-frankie:
	mkdir -p test
	v-annotate.pl \
		--mdir data/vadr-models-corona-1.1-1 \
		--mkey corona \
		--mxsize 64000 \
		data/Fr4NK_revcomp.fa \
		test/frankie-vadr









