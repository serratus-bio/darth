mkdir test/frankie-vadr
grep ^NAME data/vadr-models-corona-1.1-1/corona.cm | sed 's/^NAME *//' > test/frankie-vadr/frankie-vadr.vadr.cm.namelist
cp data/Fr4NK_revcomp.fa test/frankie-vadr/frankie-vadr.vadr.in.fa
/home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/esl-seqstat --dna -a test/frankie-vadr/frankie-vadr.vadr.in.fa > test/frankie-vadr/frankie-vadr.vadr.seqstat
/home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/cmscan  -T -10 --cpu 0 --trmF3 --noali --hmmonly --tblout test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout data/vadr-models-corona-1.1-1/corona.cm test/frankie-vadr/frankie-vadr.vadr.in.fa > test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout > test/frankie-vadr/frankie-vadr.vadr.std.cls.stdout
rm test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout > test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout
rm test/frankie-vadr/frankie-vadr.vadr.std.cls.s0.tblout
grep -v ^# test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout | sed 's/  */ /g' | sort -k 2,2 -k 3,3rn > test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout.sort
/home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/cmfetch data/vadr-models-corona-1.1-1/corona.cm NC_010438 | /home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/cmsearch  -T -10 --cpu 0 --hmmonly  --noali  --tblout test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.tblout - test/frankie-vadr/frankie-vadr.vadr.NC_010438.fa > test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.stdout > test/frankie-vadr/frankie-vadr.vadr.std.cdt.NC_010438.stdout
rm test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.tblout > test/frankie-vadr/frankie-vadr.vadr.std.cdt.NC_010438.tblout
rm test/frankie-vadr/frankie-vadr.vadr.std.cdt.s0.tblout
cat test/frankie-vadr/frankie-vadr.vadr.std.cdt.NC_010438.tblout | grep -v ^# | sed 's/  */ /g' | sort -k 1,1 -k 15,15rn -k 16,16g > test/frankie-vadr/frankie-vadr.vadr.std.cdt.tblout.sort
/home/ubuntu/repos/darth/third-party/vadr/Bio-Easel/scripts/esl-ssplit.pl -v -r -n test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa 2 > test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa.esl-ssplit
rm test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa.esl-ssplit
/home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/cmfetch data/vadr-models-corona-1.1-1/corona.cm NC_010438 | /home/ubuntu/repos/darth/third-party/vadr/infernal/binaries/cmalign  --dnaout --verbose --cpu 0 --ifile test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.ifile -o test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.stk --tau 0.001 --mxsize 16000.00 --sub --notrunc -g --fixedtau - test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa.1 > test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.stdout 2>&1
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.stdout > test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.stdout
rm test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.stdout
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.ifile > test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.ifile
rm test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.ifile
rm  test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa.1
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.1.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.2.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.3.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.4.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.5.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.6.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.7.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
cat test/frankie-vadr/frankie-vadr.vadr.NC_010438.CDS.8.fa >> test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa
/home/ubuntu/repos/darth/third-party/vadr/ncbi-blast/bin/blastx -num_threads 1 -num_alignments 20 -query test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa -db data/vadr-models-corona-1.1-1/NC_010438.vadr.protein.fa -seg no -out test/frankie-vadr/frankie-vadr.vadr.NC_010438.blastx.out
/home/ubuntu/repos/darth/third-party/vadr/vadr/parse_blast.pl --program x --input test/frankie-vadr/frankie-vadr.vadr.NC_010438.blastx.out > test/frankie-vadr/frankie-vadr.vadr.NC_010438.blastx.summary.txt
rm  test/frankie-vadr/frankie-vadr.vadr.cm.namelist test/frankie-vadr/frankie-vadr.vadr.in.fa test/frankie-vadr/frankie-vadr.vadr.in.fa.ssi test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout test/frankie-vadr/frankie-vadr.vadr.std.cls.stdout test/frankie-vadr/frankie-vadr.vadr.std.cls.tblout.sort test/frankie-vadr/frankie-vadr.vadr.NC_010438.fa test/frankie-vadr/frankie-vadr.vadr.std.cdt.NC_010438.tblout test/frankie-vadr/frankie-vadr.vadr.std.cdt.NC_010438.stdout test/frankie-vadr/frankie-vadr.vadr.std.cdt.tblout.sort test/frankie-vadr/frankie-vadr.vadr.NC_010438.a.fa test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.stdout test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.ifile test/frankie-vadr/frankie-vadr.vadr.NC_010438.align.r1.s0.stk test/frankie-vadr/frankie-vadr.vadr.NC_010438.pv.blastx.fa test/frankie-vadr/frankie-vadr.vadr.NC_010438.blastx.out test/frankie-vadr/frankie-vadr.vadr.NC_010438.blastx.summary.txt
# Fri Jun 26 00:07:04 UTC 2020
# Linux ip-172-31-49-23 5.3.0-1019-aws #21~18.04.1-Ubuntu SMP Mon May 11 12:33:03 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
[ok]
