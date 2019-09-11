## allocate each kmer of every example 
## calculate each cluster percentage in every example
## add the VDJ information; the kmer need consist with VDJ to allocate to group;
## revised the frequency caculate
## add the clone frequency
## tcl,2018/8/9
## add clinic information 
## tcl, 2018/9/12
## add train & test information 
## tcl, 2018/10/23


#!/usr/bin/perl -w
use strict;

die "perl $0 <AllKmer_<15/18/19>_<cluster_number>_(VDJ)_cluster.txt> <Group_disease_list.txt> <cluster_number> <Clinic_infor> <OutFold>\n"  unless (@ARGV == 5);

## --------------- mk hash of disease specific kmer with its cluster number ----------------##

open SK,"< $ARGV[0]" or die;

my %kmerC;

while(my $line = <SK>){

## AAA_003 389
	chomp $line;

	my $kmer = (split /\s+/,$line)[0];
	my $cluster = (split /\s+/,$line)[-1];

	$kmerC{$kmer} = $cluster;
}

## ------------------- mk hash of disease clinic infor with its id ------------------------##


open CI,"< $ARGV[3]" or die;

my %Clinic_infor;
my %Status;

while(my $line = <CI>){

## R0160801369     Dermatophagoides_positive
	chomp $line;

	my $id = (split /\t/,$line)[0];
	my $clinic = (split /\t/,$line)[1];
	my $status = (split /\t/,$line)[-1];
	
	$Clinic_infor{$id} = $clinic;

	$Status{$id} = $status;
}


## --- Read each example, and split clone into kmer, allocate each kmer of every example --##

my $outName_locate = $ARGV[1];
my $outName = (split /\//, $outName_locate)[-1];
   $outName =~ s/\.\.\///g;
   $outName =~ s/\.list\.txt//;
   $outName =~ s/_list\.txt//;
   $outName =~ s/\.CDR3_AA\.txt//;

 my $allkmer_fold = $ARGV[0];
 my $allkmer = (split /\//, $allkmer_fold)[-1];
 $allkmer =~ s/AllKmer_//;
 $allkmer =~ s/_VDJ_cluster.txt//;

my $OutFold = $ARGV[4];

open O,"> $OutFold/Allocate_kmer_group\_$outName\_$allkmer\.Freq\.txt";
open OO,"> $OutFold/Allocate_kmer_group\_$outName\_$allkmer\.Freq_redundant\.txt";

## -- make title -- ##
	print O "Name\tStatus\t";

	for(my $g = 1; $g <= $ARGV[2] -1 ; $g ++){
		print O "$g\t";
	}

	print O "$ARGV[2]\n";


##-- start here --##

open I,"< $ARGV[1]" or die;

while(my $file = <I>){

##/ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/K-mer/NineDiseases/NineDisease_privateClone/DB/Health_18_private_1.AA_CDR3.txt
	chomp $file;

	open F,"< $file" or die;

	my $file_fold = (split /\//, $file)[-1];
	my	$fileN = (split /_DisSpecal_/, $file_fold)[0];
		##CL100046485_L01_61 / R0160800341

	my	$fileN_clinic;
	my  $sample_status;

	if(exists  $Clinic_infor{$fileN}){

		$fileN_clinic = $Clinic_infor{$fileN};

		$sample_status = $Status{$fileN};
	

	print OO "$fileN\t";
	print O "$fileN_clinic\t$sample_status\t";

	my $kmerT = 0;
	my @groupS;

	my %Kmer_CF;

	while(my $line = <F>){

#CASSLAGATVGANVLTF       7276    0.134794433856894       6       10      1

		chomp $line;

		my $seq = (split /\t/,$line)[0];
		my $cloneFre = (split /\t/,$line)[2];

		$seq = uc($seq);
		
		my $VE = (split /\t/,$line)[3];
		my $JS = (split /\t/,$line)[4];
		
		my $cloneKmerT = (length $seq) - 2;

		for(my $i = 1; $i <= length $seq; $i ++){

			my $kmer = substr($seq, $i -1, 3);

			next if (length $kmer) != 3;

			$kmerT ++;

				## add VDJ location infor
				my $V = 0;
				my $INT = 0;
				my $J = 0;
				my $m = $i;

					for( my $g = 1; $g <= 3; $g ++){

						if($m <= $VE){
							$V ++;
						}
					
					elsif(($m > $VE) & ($m < $JS)){
						$INT ++;
						}
					
					else{
						$J ++;
					}
		
					$m ++;
					}

			my $vij = join("",$V,$INT,$J);
			my $kmer_vij = join("_",$kmer,$vij);
			## AAA_003

			## find kmer group in reference
			#my $group = $kmerC{$kmer_vij};

			## add the clone freq to kmer
			my $cloneFreR = $cloneFre / $cloneKmerT;
			#my $groupT = join("-",$group,$cloneFreR);
			
			## combine the kmer with VDJ location

			## AAA_003 -->  0.22
			if(defined $Kmer_CF{$kmer_vij}){
				$Kmer_CF{$kmer_vij} .= $cloneFreR;
			}
			else{
			$Kmer_CF{$kmer_vij} = $cloneFreR;
			}

				#print "$kmer\t$group\n";
				#push @groupS, $group;
			}

		}
	


#### counting each group total clone frequency

	my %cloneFreT;

	for(my $g = 1; $g <= $ARGV[2]; $g ++){

		my $Group_freT = 0;
		my $KmerF = 0;

		## AAA_003 -->  0.22
		foreach my $kmer (keys %Kmer_CF){

			my $cloneF = $Kmer_CF{$kmer};
			
			my $group = $kmerC{$kmer};
			#my $group = (split /-/,$Group_Fre)[0];

			next if ($group != $g);
	
			#my $cloneF = (split /-/,$Group_Fre)[1]; 
			
			$KmerF = $KmerF + $cloneF;
			
			}

		#print "$g\n";
		if($g != $ARGV[2] ){
		print O "$KmerF\t";
		print OO "$KmerF\t";
		}
		else{
		print O "$KmerF\n";
		print OO "$KmerF\n";
		}

	}

}
#else{
#	print "$fileN\n";
#}
}
