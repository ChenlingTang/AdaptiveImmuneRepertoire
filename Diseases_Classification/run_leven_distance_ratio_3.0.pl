####### grep bunch of clone diseases's special clone from list of XXX_CDR3_AA ######### 
##################### based on  the leven distance directly  ##########################
############### 3.0; minor modified, allow example all clone taking####################

############ loading leven_calculate.R --------------------------------#################

die "perl $0 <CDR3_list.txt> <Sepcial_clone> <TOP_number(ALL for all clone)> <leven_dis cutoff>\n" unless (@ARGV == 4);

my $topN = $ARGV[2];
my $leveDis_cutoff = $ARGV[3];
#mkdir(`mkdir Specail_LevenDist_TOP$topN_$leveDis_cutoff`);

my $SpecialClone = $ARGV[1];

#system(`mkdir Leven\_$leveDis_cutoff\_$topN\Clone`);
#######---------------- run leven_calculate.R -------------########

open F,"< $ARGV[0]" or die;
my %AN;

while(my $file = <F>){

	chomp $file;

	my $id = (split /\//,$file)[-1];
	$id =~ s/_CDR3_AA\.frequency_VDJ\.txt//;

	if ($topN eq "ALL"){
		$fileT = `wc -l $file` ;
		$topNum = (split/\s/, $fileT)[0];
	}
	else{
		$topNum = $topN;
	}
	#print "$fileT\t$topN\n";
	system(`/hwfssz1/ST_HEALTH/Immune_And_Health_Lab/Public_Software/R/R-3.4.1/bin/Rscript /ldfssz1/ST_HEALTH/Immune_And_Health_Lab/PopImmDiv_P17Z10200N0271/ChenlingTang/K-mer/ClassifyFinal/3-LevenDis_extend/leven_calculate.R $file $SpecialClone $topNum $leveDis_cutoff $id`);

	system(`sort leven_dis\_$leveDis_cutoff\_$id\_txt | uniq > leven_dis\_$leveDis_cutoff\_$id\.txt`);
	system(`rm leven_dis\_$leveDis_cutoff\_$id\_txt`);

	print "$id leven distance calculate done\n";

	## read leven out put

	open L,"< leven_dis\_$leveDis_cutoff\_$id\.txt" or die;

	my @leven;

	while(my $line = <L>){
		
		chomp $line;

		push @leven, $line;

	}

	system(`rm leven_dis\_$leveDis_cutoff\_$id\.txt`);

	## read file

	open I,"< $file";

    open O,"> $id\_DisSpecal_leven$leveDis_cutoff.CDR3_AA.txt";

	while(my $line = <I>){

		chomp $line;
		
		next if $line =~ m/\*/;

		my $clone = (split /\t/, $line)[0];
	
		if(grep /^$clone$/, @leven){
			print O "$line\n";
		}
	}
}

close F;

