#!/usr/bin/perl
use warnings;
use strict;
use English;

##format should be perl parseReblast.pl fastaFile.fa file.blast.tab.gz > outputfile.txt

if(@ARGV == 0) {
    print STDERR "Usage: perl parseReblast.pl blastedFastaFile.fa blastOutput.tab.gz > ouputFile\n";
    print STDERR "Output file is query, gi, percent identity, alignment length/n";
    die;
}

my %readLengthHash;
my $newRead;
my $maxBitscore;
my $minIdentity = 80; # Arbitrary cutoff

@ARGV = map { s/(.*\.gz)\s*$/gzip -dc < $1|/;$_ } @ARGV;


my $inputFileName = shift;
open INPUTFILE, "$inputFileName" or die "$OS_ERROR Could not open first input\nWell, crap\n";
local $/ = "\n>"; #change the input delimiter to > so the script pulls in the whole fasta entry
while (my $input = <INPUTFILE>){
    chomp $input;
    my ($readName, $sequence) = split "\n", $input;
    $readName =~ s/>//;
    $readLengthHash{$readName} = length($sequence);
}
close INPUTFILE;

local $/ = "\n";
print "#gi\tquery\tidentity\talignmentlength\n"; #header

my $inputFile2Name = shift;
open INPUTFILE2, "$inputFile2Name" or die "$OS_ERROR Could not open second input\nWell, crap\n";
while (my $input = <INPUTFILE2>){
    chomp $input;
    goThroughBlast($input);
}
close INPUTFILE2;

sub goThroughBlast {
    if($_[0] =~ /^\#/){
        $newRead = 1;
    } else {
        processBlast($_[0]);
    }
}

sub processBlast {
    if($newRead == 1) {
        processFirstRead($_[0]);
    } else {
        processOtherReads($_[0]);
    }
}

sub processFirstRead {
    my ($queryid, $subjectid, $identity, $alignmentlength, $mismatches, $gapopens, $qstart, $qend, $sstart, $send, $evalue, $bitscore) = split "\t", $_[0];
    $maxBitscore = $bitscore;
    $subjectid =~ s/gi\|//;
    $subjectid =~ s/\|.+//;
    $identity = ((($qend - $qstart + 1) - $mismatches - $gapopens) / $readLengthHash{$queryid}) * 100;
    if($identity >= $minIdentity) {
	print join("\t", $subjectid, $queryid, $identity, $alignmentlength) . "\n"; 
	$newRead=0;
    }
}

sub processOtherReads {
    my ($queryid, $subjectid, $identity, $alignmentlength, $mismatches, $gapopens, $qstart, $qend, $sstart, $send, $evalue, $bitscore) = split "\t", $_[0];
    if($bitscore == $maxBitscore) {
        $subjectid =~ s/gi\|//;
        $subjectid =~ s/\|.+//;
        $identity = ((($qend - $qstart + 1) - $mismatches - $gapopens)/ $readLengthHash{$queryid}) * 100;
	if($identity >= $minIdentity) {
	    print join("\t", $subjectid, $queryid, $identity, $alignmentlength)."\n"; 
	}
    }
}
