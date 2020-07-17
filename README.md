# Darth #

Darth is a container for running VADR and other tools for annotating
novel coronavirus genomes with no near neighbor.


### Installation ###

Note: For VADR to run smoothly, the container should be provided with
at least 64G of virtual memory. If you don't have that much RAM to
spare, consider creating a swapfile on SSD-based instance storage.

You can fetch the following repo from DockerHub: `taltman/darth:maul`

### Running ###

For an example of running darth against Frankie, run the following:

make test-docker-frankie

#### Arguments to darth.sh

1. SRA accession
2. Path to input genome FASTA file
3. Path to single (compressed) FASTQ file with all of the reads corresponding to the SRA accession. Or enter "none" if no reads
4. Data directory (leave this as "/root/data")
5. Top-level output directory path. This directory is the one that VADR will try to
create its own output directory inside of. So this directory should
already exist, and will be mounted by Docker for the image to access
in read/write mode. In the Makefile example, this is also where the genome and FASTQ
files are placed.
6. Number of CPUs for various programs within Darth to utilize
