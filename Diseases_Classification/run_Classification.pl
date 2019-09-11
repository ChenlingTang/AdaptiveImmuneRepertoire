## help to run Classification.R 

#!/usr/bin/perl -w
use strict;

die "perl $0 <Allocate_kmer_group_list.txt>\n" unless (@ARGV == 1);

open IN,"<$ARGV[0]" or die;
open XGO,"> All_xgboost_reuslt.txt";
open NNO,"> All_nnet_reuslt.txt";

while(my $file = <IN>){

	chomp $file;

	my $file_name = (split /\//, $file)[-1];
		$file_name =~ s/Allocate_kmer_group_//;
		$file_name =~ s/.Freq.txt//;

		my $level = (split /_ALLClone_18_/, $file_name)[0];
		my $cluster = (split /_ALLClone_18_/, $file_name)[-1];

	#system(`Rscript /ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/Allergy/StartOver/IMisc_clone_ABS_Health/Dermatophagoides_related_Clone/Classified/Result/Classification.R $file $file_name`);
	#print "Rscript /ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/Allergy/StartOver/IMisc_clone_ABS_Health/Dermatophagoides_related_Clone/Classified/Result/Classification.R $file $file_name\n";

	open XG,"< $file_name\_xgbost_result.txt" or die;

	while (my $line = <XG>){
		
		chomp $line;

		if ($line =~ m/^Accuracy\s\S*$/){
			my $accuracy = $line;
			
			my $accuracy_num = (split /\s/, $accuracy)[-1];

			print XGO "$file_name\t$level\t$cluster\t$accuracy_num\n";
		}
	}

	open NN,"< $file_name\_nnet_result.txt" or die;

	while (my $line = <NN>){
		
		chomp $line;

		if ($line =~ m/^Accuracy\s\S*$/){
			my $accuracy = $line;
			
			my $accuracy_num = (split /\s/, $accuracy)[-1];

			print NNO "$file_name\t$level\t$cluster\t$accuracy_num\n";
		}
	}

	print "$file_name done\n"
}