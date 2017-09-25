#!/usr/bin/perl
use strict;
use warnings;

my %barcodeHash;
my $filenameStorage="placeholder";
my $counter=0;

my $barcodeFile=shift;
open INPUTFILE, "$barcodeFile" or die "Could not open input\nWell, crap\n";
while (my $input = <INPUTFILE>){
    chomp $input;
    my ($sample,$barcodeName,$barcodeSeq) = split "\t", $input;
    $barcodeHash{$barcodeName}{barcodeSeq}=$barcodeSeq;
    $barcodeHash{$barcodeName}{sample}=$sample;
}
close INPUTFILE;

while(<>){
    my $header = $_;
    my $sequence = <>;
    chomp $header;
    chomp $sequence;
    my $filename=$ARGV;
    if($filename eq $filenameStorage){
	$counter++;
    }else {
	$counter=1;
    }
    $filenameStorage=$filename;
    $filename =~ s/.+\///;
    $filename =~ s/.fasta//;
    $header =~ s/[>\@:-]//g;
    $header =~ s/\|.+//;
    my $newHeader=">".$barcodeHash{$filename}{sample}."_$counter\t".$header."\torig_bc=".$barcodeHash{$filename}{barcodeSeq}."\tnew_bc=".$barcodeHash{$filename}{barcodeSeq}."\tbc_diffs=0";
    
    print "$newHeader\n$sequence\n";
}

