#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use Cwd;

my $dir = getcwd;

die "perl $0 <Folds>\n" unless (@ARGV != 0);

`mkdir $dir/5Race`;
`mkdir $dir/Multiple`;

foreach my $fold(@ARGV){

	my $name;

	print "$fold\n";

	if($fold =~ m/aim/){

		my @names = (split /\-/, $fold);

		shift @names;

		shift @names;

		shift @names;

		$name = join("-", @names)	
	
	}
	else{

		my $num = my @Num = (split /\-/, $fold);

		$name = join("-", (split /\-/, $fold)[1..($num-1)]);

	}

	print "$name\n";


	my $add = (split /\-/, $fold)[0];

	$add =~ s/Sample_//;

	## change fold name
	`cp -r $fold $name`;
	print "cp $fold $name\n";

	`ls $name/* > $add\_file.txt`;
	print "ls $name* > $add\_file.txt";

	die;
	
	open IN,"< $add\_file.txt" or die;

	open OUT, "> $add\_file.sh";

	while(my $line = <IN>){

		chomp $line;

		print OUT "mv $line ";	

		$line =~ s/\-aim\-//;
		
		$line =~ s/\/$add//;

		print OUT "$line\n";

	}

	close OUT;

	#`sh $add\_file.sh`;

	#`rm $add\_file.txt`;

	#`rm $add\_file.sh`;

}