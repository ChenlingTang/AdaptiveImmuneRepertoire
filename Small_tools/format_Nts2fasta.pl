#!/usr/bin/perl -w
use strict;

die "perl $0 <Nts-file>\n" unless (@ARGV == 1);

open IN,"< $ARGV[0]";

my $line_num = 0;

while (my $line = <IN>){

	chomp $line;

	my $name = (split /\t/, $line)[0];

	my $sequence = (split /\t/, $line)[-1];
	
	$line_num ++;

	print ">$name\_$line_num\n$sequence\n";
}