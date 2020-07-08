#!/bin/bash

vdb-dump -f tab \
	 -C SPOT_ID,NAME,READ_START,READ,QUALITY \
	 -R `echo "$@" | tr ' ' ','` \
	 ERR2756788

