#!/usr/bin/perl -w
use strict;
use Data::Dumper;


die "perl $0 <query_sequence> <XXX.fq>\n" unless (@ARGV == 2);

$/ = "@";

open IN,"< $ARGV[1]";

readline IN;

my $out = $ARGV[1];

$out =~ s/fq//;

my $match = $ARGV[0];

my $len = length($match);

my %START;

my $total = 0;

my $match_seq = 0;

while(my $line = <IN>){

	chomp $line;

	$total ++;

	my @lines = (split /\n/, $line);

	my $sequence = $lines[1];

	while ($sequence =~ m/$match/g){

		$match_seq ++;

		my $end = pos($sequence);

		my $start =  $end - $len + 1;

		my $value = join("-", $start, $end);

		if(defined $START{$value}){

			$START{$value} += 1;
		}
		else{

			$START{$value} = 1;
		}
	}

}

my $match_ratio = $match_seq / $total * 100;

print "Match: $match_seq\t$match_ratio\n";

print Dumper (\%START);