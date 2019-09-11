### convergent clones appears in multiple diseases into larger group.
## Input: Disease_special_Kmer_atchey.txt

#!/usr/bin/perl -w
use strict;

die "perl $0 <Disease_special_Kmer_atchey.txt> <OUTPUT_name>\n" unless (@ARGV == 2);

open IN,"< $ARGV[0]" or die;
open O,"> $ARGV[1]" or die;


while(my $line = <IN>){
	
	chomp $line;

	my @ll = (split /\t/,$line);
	my $dis = shift @ll;
	#print "$dis\n";
	my $remian = join("\t",@ll);

	my @dis_c;

	if($dis =~ m/:/g){

		if($dis =~ m/Pathogens/g){
			push @dis_c, "Pathogens";
		}
		
		if($dis =~ m/Cancer/g){
			push @dis_c, "Cancer";
		}
		
		if($dis =~ m/Autoimmune/g){
			push @dis_c, "Autoimmune";
		}
		
		if($dis =~ m/Other/g){
			push @dis_c, "Other";
		}

		my @dis_s = sort @dis_c;
		my $dis_n = join("_", @dis_s);
	
		print O "$dis_n\t$remian\n";
	}

	else{
		print O "$line\n";
	}

}


