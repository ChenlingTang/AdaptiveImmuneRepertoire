## use the simple version of database
##  >IGHV3-75_GeneID:28407

#!/usr/bin/perl -w
use strict;

die "perl $0 <germline_db> <List of alignment.clns\tChains>\n" unless (@ARGV == 2);

## read germline database

open DB,"<$ARGV[0]" or die;

 my %db;

$/ = ">";

while (my $line = <DB>) {
	
	chomp $line;

	my @genes = (split /\n/, $line);

	my $title =  shift @genes;

	my $name = (split /\_/, $title)[0];

	my $gene = join("", @genes);

	my $N = uc($name);
	
	$db{$N} = $gene;
	#print "$N\t$gene\n";
}

$/ = "\n";

close DB;

## deal with alignment clns

open IN,"<$ARGV[1]" or die;

while(my $line2 = <IN>){
	
	chomp $line2;

	my $line = (split /\t/, $line2)[0];

	my $chains = (split /\t/, $line2)[1];

	my $tem_out = (split /\//, $line)[-1];

	$tem_out =~ s/\.alignment\.clns/_5utr\.txt/;

	#print "IN: $line\tOUT: $tem_out\n";

	`mixcr exportClones -o -t --chains $chains --preset min -fraction -aaFeature CDR3 -chains -nFeatureImputed V5UTRGermline -f $line $tem_out`;

	#print "mixcr exportClones -o -t --chains $chains --preset min -fraction -aaFeature CDR3 -chains -nFeatureImputed V5UTRGermline -f $line $tem_out";

	open INN,"< $tem_out" or die;

	readline INN;

	my $out = (split /\//, $line)[-1];

	$out =~ s/\.alignment\.clns/_full\.txt/;

	open OUT,"> $out";

	print OUT "cloneCount\tcloneFraction\tChains\tbestVHit\tbestDHit\tbestJHit\tbestCHit\tnSeqCDR3\taaSeqCDR3\tFullLength\n";

	while (my $l = <INN>) {
		
		chomp $l;

		## germline V --------------------------
		my $hit_V = (split /\t/, $l)[1];
	
		my $germ_V;

		my $v = "";

		if($hit_V =~ /\S+/){

			$v = (split /\*/, $hit_V)[0];

			$germ_V = $db{$v} if (defined $db{uc($v)});
		
		}

		## germline J --------------------------
		my $hit_J = (split /\t/, $l)[3];

		my $germ_J;

		my $j = "";

		if($hit_J =~ /\S+/){

			$j = (split /\*/, $hit_J)[0];

			$germ_J = $db{$j} if (defined $db{uc($j)});

		}

		## germline C --------------------------
		my $hit_C = (split /\t/, $l)[4];

		my $germ_C = "";

		my $c = "";

		if($hit_C =~ /\S+/){

			$c = (split /\*/, $hit_C)[0];

			$germ_C = $db{$c} if (defined $db{uc($c)});

		}

		## join part V ------------------------ 
		my $cdr3_seq = (split /\t/, $l)[5];

		my $cdr3_seq_pV = substr($cdr3_seq, 0, 8);

		my $germ_V_P;

		if($germ_V =~ m/$cdr3_seq_pV/g){

			my $V_pos = pos($germ_V);

			$germ_V_P = substr($germ_V, 0, $V_pos);

		}
		else{

			$germ_V_P = similarV($cdr3_seq_pV, $germ_V);

		}

		## join part J -------------------------
		my $cdr3_seq_lenth = length($cdr3_seq);

		my $cdr3_seq_pJ = substr($cdr3_seq, ($cdr3_seq_lenth -4), );

		my $germ_J_P;

		if($germ_J =~ m/$cdr3_seq_pJ/g){

			my $J_pos = pos($germ_J);

			$germ_J_P = substr($germ_J, $J_pos, );

		}
		else{

			$germ_J_P = similarJ($cdr3_seq_pJ, $germ_J);

		}

		## join together

		my $utr = lc((split /\t/, $l)[-1]);

		my $germ_V_P_lc = lc($germ_V_P);

		my $germ_J_P_lc = lc($germ_J_P);

		my $germ_C_lc = lc($germ_C);

		my $full = join("", $utr, $germ_V_P_lc, $cdr3_seq, $germ_J_P_lc, $germ_C_lc);
			
		my $count = (split /\t/, $l)[0];

		my $freq = (split /\t/, $l)[6];

		my $chain = (split /\t/, $l)[8];

		my $cdraa = (split /\t/, $l)[7];

		my $hit_D = (split /\t/, $l)[2];

		my $d = "";

			if($hit_D =~ /\S+/){

				$d = (split /\*/, $hit_V)[0];
			}
		
		print OUT "$count\t$freq\t$chain\t$v\t$d\t$j\t$c\t$cdr3_seq\t$cdraa\t$full\n";
	}
}


## find the similar overlap region
sub similarV
{

	my ($cdr3_seq_pV, $germ_V) = @_;

	my $germ_V_len = length $germ_V;

	for(my $n=1; $n <= $germ_V_len; ++$n){

		my $germ_V_tail = substr($germ_V, ($germ_V_len-8-$n),8);

		my $levenDis = levenshtein($germ_V_tail, $cdr3_seq_pV);
		
		next if ($levenDis>3);

		my $germ_V_P = substr($germ_V, 0, ($germ_V_len-8-$n));
		
		return $germ_V_P;
	}

}

sub similarJ
{

	my ($cdr3_seq_pJ, $germ_J) = @_;

	my $germ_J_len = length $germ_J;

	for(my $n=0; $n <= ($germ_J_len-4); ++$n){

		my $germ_J_head = substr($germ_J, (0+$n), 4);

		my $levenDis = levenshtein($germ_J_head, $cdr3_seq_pJ);
		
		next if ($levenDis>1);

		my $germ_J_P = substr($germ_J,(0+$n+4), );
		
		return $germ_J_P;
	}

}

sub levenshtein
{
    # $s1 and $s2 are the two strings
    # $len1 and $len2 are their respective lengths
    #
    my ($s1, $s2) = @_;
    my ($len1, $len2) = (length $s1, length $s2);

    return $len2 if ($len1 == 0);
    return $len1 if ($len2 == 0);

    my %mat;

    for (my $i = 0; $i <= $len1; ++$i)
    {
        for (my $j = 0; $j <= $len2; ++$j)
        {
            $mat{$i}{$j} = 0;
            $mat{0}{$j} = $j;
        }

        $mat{$i}{0} = $i;
    }

    my @ar1 = split(//, $s1);
    my @ar2 = split(//, $s2);

    for (my $i = 1; $i <= $len1; ++$i)
    {
        for (my $j = 1; $j <= $len2; ++$j)
        {

            my $cost = ($ar1[$i-1] eq $ar2[$j-1]) ? 0 : 1;


            $mat{$i}{$j} = min([$mat{$i-1}{$j} + 1,
                                $mat{$i}{$j-1} + 1,
                                $mat{$i-1}{$j-1} + $cost]);
        }
    }


    return $mat{$len1}{$len2};
}


# minimal element of a list

sub min
{
    my @list = @{$_[0]};
    my $min = $list[0];

    foreach my $i (@list)
    {
        $min = $i if ($i < $min);
    }

    return $min;
}
