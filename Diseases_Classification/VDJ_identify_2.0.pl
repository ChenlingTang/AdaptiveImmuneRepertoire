## 2.0, modified output name

#!/usr/bin/perl -w
use strict;

die "perl $0 <XX.strt.list.txt> <output_date_fold>" unless (@ARGV == 2);

open IN,"< $ARGV[0]";

my $out = $ARGV[0];
$out =~ s/input/CDR3_AA/;

open O,"> $out";

my $targ = $ARGV[1];

while(my $file = <IN>){
	
	chomp $file;

	#print $file;
	open GZ,"zcat $file |" or die;
	
	my %Idenf;
	
	while(my $line = <GZ>){

		next if $line =~ m/^#/;
		next if $line =~ m/out-of-frame/;
		
		my @ll = split("\t",$line);

		my $CDR_AA = $ll[8];
		my $CDR_NT = $ll[7];	
		## CDR3
		my $CDR3_s = $ll[5];
		my $CDR3_e = $ll[6];

		## V
		my $V_s = $ll[23];
		my $V_e = $ll[24];

		## J
		my $J_s = $ll[43];
		my $J_e = $ll[44];

		my $V_END = ($V_e - $CDR3_s + 1)/3;
		my $V_END_I = int(($V_e - $CDR3_s + 1)/3);
			if($V_END == $V_END_I){
			}
			else{
				$V_END_I = $V_END_I + 1;
			}

		my $J_START = ($J_s - $CDR3_s)/3;
		my $J_START_I = int(($J_s - $CDR3_s)/3); 
			if($J_START == $J_START_I){
			}
			else{
				$J_START_I = $J_START_I + 1;
			}

		my $identifer = join("_", $V_END_I,$J_START_I);

		next if (defined $Idenf{$CDR_AA});

		$Idenf{$CDR_AA} = $identifer;

		#print "$CDR_NT\t$CDR_AA\t$identifer\n";

	}

	$file =~ s/\.final//;
	$file =~ s/\.structure/\_CDR3\_AA\.frequency/g;
	#print "$file\n";
	open F,"zcat $file |" or die;
	
	my $outname = (split /\//, $file)[-1];

	$outname =~ s/\.gz/_VDJ\.txt/;

	open OUT,"> $targ/$outname";
	
	print O "$targ/$outname\n";
	
	while(my $line = <F>){
		chomp $line;

		my $AA = (split /\t/,$line)[0];
	
		my $identifer = $Idenf{$AA};

		my $V_END_I= (split /_/,$identifer)[0];
		my $J_START_I = (split /_/,$identifer)[1];

		print OUT "$line\t$V_END_I\t$J_START_I\n";
	}

close OUT;

}

close IN;
close O;