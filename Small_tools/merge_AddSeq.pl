#!/usr/bin/perl -w
use strict;

die "perl $0 <file_1> <file_2>\n" unless (@ARGV == 2);


open IN1,"< $ARGV[0]" or die;

readline IN1;

my %FILE1;

my %FILE1_L;

my $file1_ac;

while (my $line = <IN1>){

	chomp $line;

	$line =~ s/\"//g;

	my @lines = (split /\,/, $line);

	my $ID = shift @lines;

	my $count = shift @lines;

	$file1_ac += $count;

	my $freq = shift @lines;

	my $cdr3 = (split /\,/, $line)[7];

	$FILE1{$cdr3} = $count;

	$FILE1_L{$cdr3} = join(",",@lines);

}

close IN1;

open IN2,"< $ARGV[1]" or die;

readline IN2;

my $file2_ac;

my %FILE2_only;

my %FILE2_only_L;

while (my $line = <IN2>){

	chomp $line;

	$line =~ s/\"//g;

	my @lines = (split /\,/, $line);

	my $ID = shift @lines;

	my $count = shift @lines;

	$file2_ac += $count;

	my $freq = shift @lines;

	my $cdr3 = (split /\,/, $line)[7];

	if(defined $FILE1{$cdr3}){

		#my $n1 = $FILE1{$cdr3};
		$FILE1{$cdr3} += $count;

		#my $n2 = $FILE1{$cdr3};
		
		#print "$cdr3\t$n1\t$n2\n";
	}
	else{

		$FILE2_only{$cdr3} = $count;

		$FILE2_only_L{$cdr3} = join(",",@lines);

	}

}

close IN2;


my $out =$ARGV[0];

$out =~ s/\.csv/\_merge\.txt/;

$out =~ s/\_first//;

$out =~ s/\_secd//;


open OUT,"> $out";

my $title = `head -n 1 $ARGV[1]`;

chomp $title;

print OUT "$title\n";

#print "$file1_ac \t $file2_ac\n";

my $total = $file2_ac + $file1_ac;

my $ID;

foreach my $f1_cdr(keys %FILE1){

	my $count = $FILE1{$f1_cdr};

	my $freq = $count / $total;

	$ID ++;

	my $rl = $FILE1_L{$f1_cdr};

	print OUT "$ID\,$count\,$freq\,$rl\n";
}


foreach my $f2_cdr(keys %FILE2_only){

	my $count = $FILE2_only{$f2_cdr};

	my $freq = $count / $total;

	$ID ++;

	my $rl = $FILE2_only_L{$f2_cdr};

	print OUT "$ID\,$count\,$freq\,$rl\n";
}







