#!/usr/bin/perl -w
use strict;

my $input = $ARGV[0];

my $reverse = reverse $input;
my $reverse_UP = uc $reverse;

$reverse_UP =~ tr/GCTA/CGAT/;

print "$reverse_UP\n";
