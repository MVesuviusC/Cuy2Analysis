#!usr/bin/perl
use strict;
use warnings;
use English;

#this script takes in a fasta file and removes any entries where the sequnce length is less than the given cutoff
##usage should be perl filterShortFastq.pl 50 file_SE1.fastq.gz


my $line =1;
my $storage;

my $minLength = shift;

local $/ = "\n>"; #change the input delimiter to > so the script pulls in the whole fasta entry

while (my $input = <>){
    chomp $input;
    my ($header,@seqs) = split "\n", $input;
    $header =~ s/>//;
    my $sequence = join "", @seqs;
    $sequence =~ s/\n//g;
    if(length($sequence)>=$minLength) {
        print ">",$header,"\n", $sequence, "\n";
    }
}


