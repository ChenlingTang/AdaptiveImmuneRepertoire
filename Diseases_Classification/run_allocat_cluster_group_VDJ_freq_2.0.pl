## help script to run allocate under different kemer group;
#!/usr/bin/perl -w
use strict;

die "perl $0 <Leven_XX_ALLClone_list.txt> <XXX_clinic.txt>\n" unless (@ARGV == 2);

my $kmer_locate = "/ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/K-mer/FiveDiseases/DiseasesRelated_clone_Anay/IMUSIC_SpecialClone/Allocate_Freq_Result";

my $script_locate = "/ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/K-mer/ClassifyFinal/4-Kmer_located";

my $pwd = `pwd`;
chomp $pwd;

my $file = $ARGV[0];
chomp $file;

my $output = (split /\//, $file)[-1];
$output =~ s/_list\.txt//;

system(`mkdir $output`);

my $OutFold = join("/", $pwd, $output);

my $clinic = $ARGV[1];
chomp $clinic;

my @kmer_group = (200,300,400,500,700);

foreach my $group (@kmer_group){

	open O,"> $output/$output\-$group\_allocate.sh";

	chomp $group;

	print O "perl $script_locate/allocat_cluster_group_VDJ_freq_3.0.pl $kmer_locate/AllKmer_18_$group\_VDJ_cluster.txt $pwd/$file $group $pwd/$clinic $OutFold\n";

	system(`qsub -cwd -l vf=2.99g,p=1 -q st.q -P P18Z10200N0219 $output/$output\-$group\_allocate.sh`);
}

