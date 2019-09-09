#!/usr/bin/perl -w
use strict;
use Cwd;

die "perl $0 <Fold>\n" unless (@ARGV != 0);

my $dir = $ARGV[0];

chomp $dir;

opendir IN, $dir or die;

`mkdir $dir/5Race`;
`mkdir $dir/Multiple`;

foreach my $file(readdir IN){

	chomp $file;

	print "$file\n";

	if($file =~ /aim/){

		my $num = my @Num = (split /\-/, $file);

		my $new_file = $file;

		$new_file =  join("-", (split /\-/, $file)[3..($num-1)]);

		$new_file =~ s/\_combined//;

		`mv $dir/$file $dir/$new_file`;

		if($new_file =~ /MR/){

			`mv $dir/$new_file $dir/Multiple`;
		}
		else
		{
			`mv $dir/$new_file $dir/5Race`;
		}
	}
	else{

		my $num = my @Num = (split /\-/, $file);

		my $new_file = $file;

		$new_file =  join("-", (split /\-/, $file)[1..($num-1)]);

		`mv $dir/$file $dir/$new_file`;

		if($new_file =~ /MR/) {

			`mv $dir/$new_file $dir/Multiple`;
		}
		else
		{
			`mv $dir/$new_file $dir/5Race`;
		}

	}

}

closedir IN;
