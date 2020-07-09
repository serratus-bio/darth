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
