#!usr/bin/perl
use strict;
use warnings;
use English;

# This script takes the output from mothur and screens out any reads with less than X total occurences. 
# syntax should be perl filterMothurByCount.pl 10 file.fa.gz file.names.gz > output.fa

my $cutoff = shift;
my %namesHash;

@ARGV = map { s/(.*\.gz)\s*$/gzip -dc < $1|/;$_ } @ARGV;

my $inputFileName = shift;
open INPUTFILE, "$inputFileName" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE>){
    chomp $input;
    my @names = split "\t", $input;
    if(scalar(@names) > $cutoff) {
        $namesHash{$names[0]}=$input;
    }
}
close INPUTFILE;


my $inputFile2Name = shift;

##prep the files for writing out
my $r2fileName = $inputFile2Name;
$r2fileName =~ s/.+\///; #get rid of path and other crap
$r2fileName =~ s/unique.fa.gz\|//;
$r2fileName =~ s/unique.fasta.gz\|//;
$r2fileName =~ s/unique.fna.gz\|//;
my $r1fileName = $r2fileName;
$r2fileName = $r2fileName . "unique.filtered.fa";
$r1fileName = $r1fileName . "filtered.names";
open my $r1File, '>', "output/$r1fileName";
open my $r2File, '>', "output/$r2fileName";

local $/ = "\n>"; #change the input delimiter to \n> so the script pulls in the whole fasta entry

open INPUTFILE2, "$inputFile2Name" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE2>){
    chomp $input;
    my ($header,$sequence) = split "\n", $input;
    if(exists($namesHash{$header})) {
        print $r2File ">".$input,"\n";
	print $r1File $namesHash{$header}, "\n";
    }
}

close INPUTFILE2;


