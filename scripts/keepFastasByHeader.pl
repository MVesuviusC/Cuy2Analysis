#!/usr/bin/perl
use strict;
use warnings;

@ARGV = map { s/(.*\.gz)\s*$/gzip -dc < $1|/;$_ } @ARGV;

my %headersHash;

my $sequencesFile = shift;
open SEQFILE, "$sequencesFile" or die "Could not open sequences file\nCrap...\n";
while(my $seqHeader = <SEQFILE>) {
    chomp $seqHeader;
    $seqHeader =~ s/>//;
    my $seq = <SEQFILE>;
    chomp $seq;
    $headersHash{$seqHeader} = ">".$seqHeader."\n".$seq;
}


my $headerInputFile = shift;
open HEADERFILE, "$headerInputFile" or die "Could not open header input file\nCrap...\n";

while(my $headerInput= <HEADERFILE>) {
    chomp $headerInput;
    if(exists($headersHash{$headerInput})) {
        print $headersHash{$headerInput},"\n";
    }
}
close HEADERFILE;
