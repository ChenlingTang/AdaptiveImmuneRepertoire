## run blast for query.fasta aginst one reads.fastq.gz 
## tcl, 2018.12.24

#!/usr/bin/perl -w
use strict;

die "perl $0 <query_file.fasta> <reads_file.fastq.gz>\n" unless (@ARGV ==2);

## convert fastq into fasta

open IN,"gunzip -c $ARGV[1]|" or die;

open OUT,"> readsDB.fasta" or die;

my @reads = <IN>;

my $count = -1;

foreach my $read(@reads){

	chomp $read;

	$count ++;

	if($read =~ /^@\w+\S*\s/){
		
		$read =~ s/^@/>/;
		
		my $sequence = $reads[$count+1];
		
		chomp $sequence;

		print OUT "$read\n$sequence\n";

	}
}

close IN;

## makeblastDB
my $reads_name = $ARGV[1];

my $readsNA = (split /\//,$reads_name)[-1];

$readsNA =~ s/\.fastq\.gz//;

system("makeblastdb -in readsDB.fasta -dbtype nucl -title $readsNA -out $readsNA");

## blastn
my $query_NA = $ARGV[0];

my $query_name = (split /\//, $query_NA)[-1];

$query_name =~ s/\.fasta//;

system("blastn -outfmt 7 -db $readsNA -query $ARGV[0] -out $query_name\_$readsNA\.blast.out");

## summary blastn result

open QY,"< $ARGV[0]";

my @querys;

while(my $line = <QY>){

	chomp $line;

	if ($line =~ s/^>//){

		push @querys, $line;

	}
}

my $redsDB_Num = `wc -l readsDB.fasta`/2;

print "Total reads: $redsDB_Num\n";

#system("rm readsDB.fasta");

system("rm $readsNA*");

foreach my $query(@querys){

	open BLAST,"< $query_name\_$readsNA\.blast.out";

	my @BlastOut = <BLAST>;

	my $numberN = -1;

	foreach my $out(@BlastOut){

		chomp $out;

		$numberN ++;

		if($out =~ /Query:\s$query$/){

			my $found = $BlastOut[$numberN+2];

			chomp $found;

			if($found =~ /hits\sfound/){
				print "$query\t$found\n";
			}
			else{

				my $foundd = $BlastOut[$numberN+3];

				chomp $foundd;

				print "$query\t$foundd\n";	
			}
			
		}
	}
}













