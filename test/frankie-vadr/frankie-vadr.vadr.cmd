mkdir test/frankie-vadr
grep ^NAME data/vadr-models-corona-1.1-1/corona.cm | sed 's/^NAME *//' > test/frankie-vadr/frankie-vadr.vadr.cm.namelist
cp data/GCF_009858895.2_ASM985889v3_genomic.fna test/frankie-vadr/frankie-vadr.vadr.in.fa
/home/taltman/repos/darth/third-party/vadr/infernal/binaries/esl-seqstat --dna -a test/frankie-vadr/frankie-vadr.vadr.in.fa > test/frankie-vadr/frankie-vadr.vadr.seqstat
/home/taltman/repos/darth/third-party/vadr/infernal/binaries/cmscan  -T -10 --cpu 0 --trmF3 --noali --hmmonly --tblout test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout data/vadr-models-corona-1.1-1/corona.cm test/frankie-vadr/frankie-vadr.vadr.in.fa > test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout > test/frankie-vadr/frankie-vadr.vadr.std.cls.stdout
rm test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout > test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout
rm test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout
grep -v ^# test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout | sed 's/  */ /g' | sort -k 2,2 -k 3,3rn > test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout.sort
/home/taltman/repos/darth/third-party/vadr/infernal/binaries/cmfetch data/vadr-models-corona-1.1-1/corona.cm NC_045512 | /home/taltman/repos/darth/third-party/vadr/infernal/binaries/cmsearch  -T -10 --cpu 0 --hmmonly  --noali  --tblout test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.tblout - test/frankie-vadr/frankie-vadr.vadr.NC_045512.fa > test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.stdout

ERROR in utl_RunCommand(), the following command failed:
/home/taltman/repos/darth/third-party/vadr/infernal/binaries/cmfetch data/vadr-models-corona-1.1-1/corona.cm NC_045512 | /home/taltman/repos/darth/third-party/vadr/infernal/binaries/cmsearch  -T -10 --cpu 0 --hmmonly  --noali  --tblout test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.tblout - test/frankie-vadr/frankie-vadr.vadr.NC_045512.fa > test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.stdout

[fail]
