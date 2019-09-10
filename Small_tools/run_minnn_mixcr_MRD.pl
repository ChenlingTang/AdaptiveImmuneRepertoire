## run minnn and mixcr for mulitplex PCR

#!/usr/bin/perl -w
use strict;

die "perl $0 <name> <fq1> <fq2>\n" unless (@ARGV ==3);

my $name = $ARGV[0];

chomp $name;

my $fq1 = $ARGV[1];

chomp $fq1;

die "$fq1 not exist\n" unless (-e $fq1);

my $fq2 = $ARGV[2];

chomp $fq2;

die "fq2 not exist\n" unless (-e $fq2);

open OUT,"> $name\_MINNN_MIXCR.sh";

## minnn barcode extract
print OUT "minnn extract --input $fq1 $fq2 --oriented --output $name\_barcode\.mif --pattern \"(UMI:N{14})ctgaggaga\\*\" -f\n";

## export barcode extract fq
#print OUT "minnn mif2fastq --input $name\_barcode\.mif --group R1\=$name\_R1_extrct.fastq --group R2\=$name\_R2_extrct.fastq\n";

## correct barcodes
print OUT "minnn correct --input $name\_barcode\.mif --output $name\_correct\.mif --groups UMI\n";

##sort
print OUT "minnn sort --input $name\_correct\.mif --output $name\_sort\.mif --groups UMI\n";

## consensus
print OUT "minnn consensus --input $name\_sort\.mif --output $name\_consensus\.mif --max-consensuses-per-cluster 3 --groups UMI\n";

## export consensus fq
print OUT "minnn mif2fastq --input $name\_consensus\.mif --group R1\=$name\_consensus_R1.fq --group R2\=$name\_consensus_R2.fq\n";

## mixcr align
print OUT "mixcr align  --species hsa -OallowPartialAlignments=true -OvParameters.geneFeatureToAlign=VTranscript  --report $name\.alignReport.log $name\_consensus_R1.fq $name\_consensus_R2.fq $name\.alignment.vdjca\n";

## mixcr assemble
# print OUT "mixcr assemble --report $name\.CloneReport.log -OassemblingFeatures='CDR3' -ObadQualityThreshold=10 -OmaxBadPointsPercent=0.9  $name\.alignment.vdjca $name\.alignment.clns\n";
print OUT "mixcr assemble --report $name\.CloneReport.log -OassemblingFeatures='CDR3' $name\.alignment.vdjca $name\.alignment.clns\n";

## mixcr export
# print OUT "mixcr exportClones -o -t --preset full -m 10 -f $name\.alignment.clns $name\_all.txt\n";
print OUT "mixcr exportClones --preset full -m 10 -f $name\.alignment.clns $name\_all.txt\n";

