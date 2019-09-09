#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use Cwd;
my $dir = getcwd;

`/home/ChenglingTang/opt/OSS/ossutil64 config -e <ID.aliyuncs.com> -i <key> -k <Secret>`;

die "perl $0 <Project ID>\n Eg:s710g01013 \n\nTips:The code to check OSS:\n/home/ChenglingTang/opt/OSS/ossutil64 ls oss://delivery-data/s710/ -d\n\n
######## !!!! Please Make Sure in the correct fold !!!! ########\n (the files would downloads to current fold named as today date)\n\n" unless (@ARGV == 1);

`/home/ChenglingTang/opt/OSS/ossutil64 config -e <ID.aliyuncs.com> -i <key> -k <Secret>`;

print "Default Config:\n\tID: <ID>\n\tSecret: <Secret>\tRegion: oss-cn-shanghai\n\n";

`/home/ChenglingTang/opt/OSS/ossutil64 ls oss://delivery-data/s710/ -d > OSS_database.txt`;

## selected date
my $date = $ARGV[0];

chomp $date;

`mkdir $date`;

open IN,"cat OSS_database.txt|" or die;

print "Start downloads ...\n";
	
while (my $line = <IN>) {
	
	chomp $line;

	next unless ($line =~ m/$date/);

	print "$line\n";
	`/home/ChenglingTang/opt/OSS/ossutil64 cp -r -f --job 10 --parallel 10 $line $date`;

	`mv $date/*/*gz $date`;

	`rm -r $date/Sample*/`;

	print "Start rename and relocate ...\n";

	`perl /home/ChenglingTang/Script/OSS/CN.pl $date`;

}

close IN;