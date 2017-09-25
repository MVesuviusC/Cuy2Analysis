#!/usr/bin/perl
use strict;
use warnings;
use English;



#this script takes in a list of primers in the format primerName ForwardPrimer ReversePrimer (on each line) and a number denoting how much of the 3' end to use for matching, then it takes in a fastq file and cuts off any primers 
#the program should be run like: perl CutOffSequencFromFastqV1.pl 10 primerlist.txt sampleID-SE[1or2].fastq.gz > output.txt
#the output is a fastq file with the sequence and quality trimmed and the sample ID (from file name) and primer added to the header
#    ## You will want to screen out hits with "noPrimer" in the primer slot of the header afterwards.

my $lengthOfPrimerToMatch = shift; # this is the number of bases on the 3' end of the primer that will be matched

my %primerHash;
my %degeneratehash = ( #hash of arrays - degenerate bases with matching bases
		       W =>["A","T"],
		       S =>["C","G"],
		       M =>["A","C"],
		       K =>["G","T"],
		       R =>["A","G"],
		       Y =>["C","T"],
		       B =>["C","G","T"],
		       D =>["A","G","T"],
		       H =>["A","C","T"],
		       V =>["A","C","G"],
		       N =>["A","C","G","T"]
		       );

## Get the primers and make multiple versions for degenerate bases
my $inputFileName = shift;
open INPUTFILE, "$inputFileName" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE>){
    chomp $input;
    addPrimerToHash($input);
}

sub addPrimerToHash {
    my $input = shift; 
    my ($primerName, $primerF, $primerR) = split " ", $input;
    $primerF = trimPrimer($primerF);
    $primerR = trimPrimer($primerR);
    dealWithDegenerates($primerF,$primerName);
    dealWithDegenerates($primerR,$primerName);
}

sub trimPrimer {
    my $primer = shift;
    if(length($primer)<$lengthOfPrimerToMatch){
	die "You can't trim that much primer!!!\nYour trim length is longer than your primer!!!";
    }
    my $trimmedPrimer = substr($primer,length($primer)-$lengthOfPrimerToMatch,$lengthOfPrimerToMatch); # get the last N bases
    return($trimmedPrimer);
}

sub dealWithDegenerates {
    my $primer = $_[0];
    my $primerName = $_[1];
    if($primer =~ /[WSMKRYBDHVN]/) { #if the primer has any degenerate bases, deconvolute those and add the subsequent primers to the hash
	addDegeneratePrimer($primer,$primerName);
    } else {
	$primerHash{$primer}=$primerName;
    }
}

sub addDegeneratePrimer {
    my $primer = $_[0];
    my $primerName = $_[1];
    my @primerArray = ($primer); #make an array containing the degenerate primer
    my @tempArray = (); #make a temporary array to hold the new versions of the primers
    my $test = 1;
    while($test==1){
	for(my $i=0;$i<scalar(@primerArray);$i++) { # sort through primerArray
	    if($primerArray[$i] =~ /[WSMKRYBDHVN]/) { #if 
		push( @tempArray, getNewPrimerVersions($primerArray[$i]) );
	    } else {
		push( @tempArray, $primerArray[$i] ); #add normal primer to tempArray
	    }
	}
	@primerArray = @tempArray;
	@tempArray = ();
	if(join("",@primerArray) =~ /[WSMKRYBDHVN]/ == 1){
	    $test=1;
	} else {
	    $test=0;
	}
    }    
    for(@primerArray) {
	$primerHash{$_} = $primerName; #add these sequences to the primerHash
    }    
}

#Go through the primer, and find any degenerate bases
#Then make seperate versions of the primer for each possible sequence and add that to @primerArray
sub getNewPrimerVersions {  
    my $primer = shift; #primer sequence
    my @baseArray = split("", $primer); #split the primer up into individual bases in an array
    my @tempArray=();
    for(my $i=0;$i<scalar(@baseArray);$i++){ #go through each base in the primer
	my $nucleotide = $baseArray[$i];
	if($nucleotide =~ /[WSMKRYBDHVN]/) { #if that base has a degenerate base
	    for(@{$degeneratehash{$nucleotide}}) { #go through the possible replacements 
		my @copyArray = @baseArray; # copy this array so we can modify it
		$copyArray[$i] = $_; #then switch out the base in the copy array with a possibility
		push(@tempArray,join("",@copyArray)); #and add the new decoded primer sequence to the end of the @primerArray
	    }
	}
    }
    return @tempArray
}



for my $primerSeq (keys %primerHash) {
    print STDERR join("\t", $primerHash{$primerSeq}, $primerSeq) . "\n";
}

close INPUTFILE;



### Now, pull in the fastq 

@ARGV = map { s/(.*\.gz)\s*$/gzip -dc < $1|/;$_ } @ARGV;
my $inputFileName2 = shift;
my $line=1;
my $storage;

open INPUTFILE2, "$inputFileName2" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE2>){
    chomp $input;
    if($line==1) {
	$storage=$input;
    } elsif($line<4) {
	$storage = join("\t",$storage, $input);
    } elsif($line==4) {
	$storage = join("\t",$storage, $input);
	trimSequence($storage);
	$line=0;
    }
    $line++;
}

sub trimSequence {
    my $fastq = shift;
    my ($header, $sequence, $header2,$quality) = split "\t", $fastq;
    my @trimmedSeqPrimerQual = searchSequenceForPrimer($sequence,$quality);
    $inputFileName2 =~ s/.+DS/DS/;
    $inputFileName2 =~ s/_SE[12].fastq.gz//;
    my $newHeader = $header;
    $newHeader = $newHeader . "|" . $trimmedSeqPrimerQual[1] . "|" . $inputFileName2;
    my $newfastq = join("\n", $newHeader,$trimmedSeqPrimerQual[0],"+",$trimmedSeqPrimerQual[2]);
    print $newfastq, "\n";
}

sub searchSequenceForPrimer {
    my $sequence = shift;
    my $qual = shift;
    my $trimSeq;
    my $trimQual;
    my $primerHit="noPrimer";
    my $flag = 0;
    my @returnValue; 
    for my $primerSeq (keys %primerHash) {
	my $reverse = revComp($primerSeq);
	my $firstFifty = substr($sequence,0,50);
	if($firstFifty =~ /$primerSeq/) {
	    $flag = 1;
	    my $match = $sequence;
	    $match =~ /$primerSeq/g;
	    $trimSeq = substr($sequence, pos($match), length($sequence)- pos($match)  );
	    $trimQual = substr($qual, pos($match), length($qual)- pos($match)  );
	    $sequence = $trimSeq;
	    $qual = $trimQual;
	    $primerHit = $primerHash{$primerSeq};
	} elsif($sequence =~ /$reverse/) {
	    my $match = $sequence;
	    $match =~ /$reverse/g;
	    $trimSeq = substr( $sequence, 0, pos($match)- length($primerSeq) );
	    $trimQual = substr( $qual, 0, pos($match)- length($primerSeq) );
	    $sequence = $trimSeq;
	    $qual = $trimQual;
	    $primerHit = $primerHash{$primerSeq}; 
	} 
	#if(length($sequence)==0) {
	#    $sequence="noSequenceLeft";
	#    $qual="noSequenceLeft";
	#}
    }
    if($flag==1){
	@returnValue = ($sequence,$primerHit,$qual);
    } else {
	@returnValue = ("primerNotFound","noPrimer",$qual);
    }
    return @returnValue;
}


sub revComp{
    my $seq = shift;
    $seq =~ tr/ACGTacgt/TGCAtgca/;
    reverse($seq);
}
