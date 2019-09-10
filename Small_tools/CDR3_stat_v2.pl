#!/usr/bin/perl -w
use strict;
use Data::Dumper;

die "perl $0 <*txt>\n" unless (@ARGV >= 3);

my $file_num = @ARGV;

for(my $n = 0; $n < $file_num; ++$n){

	my $file = $ARGV[$n];

	my $clinic_id = (split /\-/,$file)[0];

	open INN,"< $file" or die;

		my %cdr3_len;

		my %Vgene;

		my %Jgene;

		open CDRL,"> $clinic_id\-CDR3Length.txt";
		open VG,"> $clinic_id\-Vgene.txt";
		open JG,"> $clinic_id\-Jgene.txt";
		#my %VJgene;

		my $lines=0;

		while(my $line = <INN>){

			chomp $line;
			
			next if ($line =~ m/^count/);

			$lines ++;

			my $cdr3nt = (split /\t/, $line)[2];

			my $cdr3nt_len = length($cdr3nt);

			if(defined $cdr3_len{$cdr3nt_len}){

				$cdr3_len{$cdr3nt_len} += 1;

			}
			else{

				$cdr3_len{$cdr3nt_len} = 1;

			}

			my $V = (split /\t/, $line)[4];

			if(defined $Vgene{$V}){

				$Vgene{$V} += 1;

			}
			else{

				$Vgene{$V} = 1;

			}

			my $J = (split /\t/, $line)[6];

			if(defined $Jgene{$J}){

				$Jgene{$J} += 1;

			}
			else{

				$Jgene{$J} = 1;

			}


		}

		foreach my $cdr3L (keys %cdr3_len){

			my $count = $cdr3_len{$cdr3L} / $lines * 100;

			print CDRL "$cdr3L\t$count\t$clinic_id\n";
		}


		foreach my $vgene (keys %Vgene){

			my $count = $Vgene{$vgene} / $lines * 100;

			print VG "$vgene\t$count\t$clinic_id\n";
		
		}

		foreach my $jgene (keys %Jgene){

			my $count = $Jgene{$jgene} / $lines * 100;

			print JG "$jgene\t$count\t$clinic_id\n";
		
		}

		close CDRL;
		close VG;
		close JG;

		close INN;
	}
