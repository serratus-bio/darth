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

#### Arguments to canonicalize_contigs.sh

1. Path to input genome FASTA file
2. Top-level output directory path. Will create a 'transeq' sub directory
3. Data directory (leave this as "/root/data")

Output:

A directory called `transeq` that has a file `canonical.fna`, that has
the assembly with the contigs rearranged, with some of the contigs
reverse-complemented, as needed. Also, the `alignments.fasta` file in
this directory should be used for tree-building.

#### Algorithm used by canonicalize_contigs.sh

First, build a model from a trusted sequence, like RefSeq or GenBank (for now, this is the RefSeq
SARS-CoV-2 genome, but more can easily be built):

1. Obtain sequence
2. Use transeq to get 6-frame translation of the whole genome
3. Use Pfam to annotate translations
4. Sort Pfam hits by alignment start base
5. Create two-column file associating Pfam model name with the sort order

Now, analyze the assembly:
1. Obtain sequence
2. Use transeq to get 6-frame translation of all contigs
3. Use Pfam to annotate translations
4. (While we are at it...) Create alignments.fasta file for tree-building
5. Use two-column model file to assign order numbers to the Pfam annotations
6. Sort the annotations based on the model order number
7. Scan the sorted annotation file in order, noting the contig ordering, and which frame each Pfam hit occurred
8. Break up the input assembly into separate contig files
9. Iterate over the contig order from step 7, reverse complement the contig file if necessary, and concatenate
10. If there are contigs with no Pfam hits in the two-column model file, append to end of assembly