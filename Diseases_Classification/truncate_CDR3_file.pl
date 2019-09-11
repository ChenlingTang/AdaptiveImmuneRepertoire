#### truncate the CDR3 freq file into custom number of clones by random or frequency

#!/usr/bin/perl -w
use strict;

die "perl $0 <list_CDR3_file> <truncate_number> <1: random / 2: frequency(high -> low)> <OUT_list_Name>\n" unless (@ARGV == 4);

open IN ,"< $ARGV[0]";
open OUT,"> $ARGV[3]";

my $tcnum = $ARGV[1];

while(my $line = <IN>){

	chomp $line;

	my @locate = (split /\//,$line);
	my $fileN = pop @locate;
	my $outLocat = join("/", @locate);

	if($ARGV[2] == 1){
	    $fileN =~ s/AA_CDR3/AA_CDR3.$tcnum\_Random/g;

	}
	else{
		$fileN =~ s/AA_CDR3/AA_CDR3.$tcnum\_HighFreq/g;

	}

	open O,"> $outLocat/$fileN";
	print OUT "$outLocat/$fileN\n";
	#print "$fileN\t$outLocat\n";

	if($ARGV[2] == 1){

		my $selectR  = `sort -R $line | head -n $tcnum`;
		print O "$selectR\n";
	}
	else{

		my $select  = `head -n $tcnum $line`;
		print O "$select\n";
	}



}