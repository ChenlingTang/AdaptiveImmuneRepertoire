## split CDR3 (all_cdr3.correct.list) into 3 length Kmer, and assign Atchey scores.

#!/usr/bin/perl -w
use strict;

die "perl $0 <all_cdr3.correct.list>\n" unless (@ARGV == 1);

###########----------- mk hash of Athchey socre -----#########
open A,"</ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/K-mer/AtcheyMatirx_kmer_3.txt";

my %Athchey;

while(my $line = <A>){
	chomp $line;

	my $kmer = (split /\t/,$line)[0];
	my $atchey = (split /\t/,$line)[-1];

	$atchey =~ s/,/\t/g;

	$Athchey{$kmer} = $atchey;
}

########----------- load CDR3, split into 3 kmer -----------######

open IN,"<$ARGV[0]";
open OUT,"> Disease_special_Kmer_atchey.txt";

while(my $line = <IN>){
	chomp $line;

	my $seq = (split /\t/,$line)[0];
		$seq = uc($seq);

	next if $seq =~ m/O/g;
	
	my $dis = (split /\t/,$line)[-1];

	for(my $i = 1; $i <= length $seq; $i ++){

		my $kmer = substr($seq, $i -1, 3);

		## rm special Amino acid or blank
		next if $kmer =~ m/-/;
		next if $kmer =~ m/X/;
		next if $kmer =~ m/B/;

		if( (length $kmer) == 3 ){

			my $atcheyS = $Athchey{$kmer};

			if(exists $Athchey{$kmer}){
			print  OUT "$dis\t$kmer\t$atcheyS\n";
			}
			else{
			print "$dis\t$seq\t$kmer\n";
			}
		}
	}
}