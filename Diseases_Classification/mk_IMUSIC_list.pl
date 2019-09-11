#!/usr/bin/perl -w
use strict;

open IN,"< $ARGV[0]";

my $out = $ARGV[0];

$out =~ s/\.txt$/_IMSIC\.txt/;

open OUT,"> $out";

while (my $line = <IN>) {

	chomp $line;

	$line =~ s/\.structure\.final/_CDR3_AA.frequency/;

	my $id = (split /\//,$line)[-1];
	my $idd = (split /\./, $id)[0];
	chomp $idd;
	chomp $line;
	#print "$line\t";

	print OUT "$line\t$idd\n";


}