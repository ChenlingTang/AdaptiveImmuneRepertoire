#!/usr/bin/perl -w
use strict;

die "perl $0 <Nts-file> <Out-line-name>\n" unless (@ARGV == 2);

open IN,"< $ARGV[0]";

my $name = $ARGV[1];

my $line_num = 0;

while (my $line = <IN>){

	chomp $line;


	$line =~ s/\s+//;

	$line =~ s/\s/\t/;

	my $freq = (split /\t/,$line)[0];
	
	my $seq = (split /\t/,$line)[-1];
	
	$line_num ++;

	print ">$name\_$line_num\_$freq\n$seq\n";
}

