#!/usr/bin/perl -w
use strict;

open F,"< $ARGV[0]" or die;

my %nameDB;

while (my $line = <F>) {
	
		chomp $line;

	my $name = (split /\t/, $line)[0];
	my $leven = (split /\t/, $line)[1];
	my $count = (split /\t/, $line)[2];
#my $freq = (split, $line)[3];

	if($leven ne "leven0"){

		next if $count == 0;

		#my $name_leven = join("_", $name, $leven);
		#my $count_freq = join("_", $count, $freq);

		++$nameDB{$name};

		#$hash{$name_leven} = $count_freq;
	}
}

my @qualify;

foreach my $name(keys %nameDB){

	if($nameDB{$name} == 6){

		push @qualify, $name;

		#print "$name\t$nameDB{$name}\n";
	}
}

open FF,"< $ARGV[0]" or die;

while (my $line = <FF>) {
	
		chomp $line;
		#print "$line\n";
		my $name = (split /\t/, $line)[0];

if( grep /^$name$/, @qualify){

	print "$line\n";

	}

}

