#!usr/bin/perl
use strict;
use warnings;
use English;

#this script takes in two fastq files and if the difference in read length between R1 and R2 is less than the specified value, the reads are printed out to files in a filteredFastq folder. Also unpaired reads are discarded. 
##Assumes that the fastq files have read number in the file name in the following format: SE1 SE2
##usage should be perl filterFastqPairsLength.pl 5 file_SE1.fastq.gz file_SE2.fastq.gz


my %r1Hash;
my $line =1;
my $storage;
my @fileArray = @ARGV;
my $lengthWindow = shift;


@ARGV = map { s/(.*\.gz)\s*$/gzip -dc < $1|/;$_ } @ARGV;

my $inputFileName = shift;
open INPUTFILE, "$inputFileName" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE>){
    chomp $input;
    if($line==1) {
        $storage=$input;
    } elsif($line<4) {
        $storage = join("\n",$storage, $input);
    } elsif($line==4) {
        $storage = join("\n",$storage, $input);
        makeR1Hash($storage);
        $line=0;
    }
    $line++;
}


sub makeR1Hash {
    my $fastq = shift;
    my ($header, $sequence, $header2,$quality) = split "\n", $fastq;
    my ($headerStub) = split " ", $header;
    $r1Hash{$headerStub} = $fastq;
}

close INPUTFILE;

$line=1;
my $inputFile2Name = shift;


##prep the files for writing out
my $r2fileName = $fileArray[2];
$r2fileName =~ s/.+\///;
$r2fileName =~ s/.gz//;
my $r1fileName = $r2fileName;
$r1fileName =~ s/SE2/SE1/;
$r1fileName =~ s/R2/R1/;
open my $r1File, '>', "filteredFastq/$r1fileName";
open my $r2File, '>', "filteredFastq/$r2fileName";

open INPUTFILE2, "$inputFile2Name" or die "$OS_ERROR Could not open first input\nWell, crap\n";
while (my $input = <INPUTFILE2>){
    chomp $input;
    if($line==1) {
        $storage=$input;
    } elsif($line<4) {
        $storage = join("\n",$storage, $input);
    } elsif($line==4) {
        $storage = join("\n",$storage, $input);
        parseFastq($storage);
        $line=0;
    }
    $line++;
}


sub parseFastq {
    my $fastq = shift;
    my ($header, $sequence, $header2,$quality) = split "\n", $fastq;
    my ($headerStub,$primerSample) = split " ", $header;
    $primerSample =~ s/[12]:N//;
    if(exists($r1Hash{$headerStub}) && (length($sequence) > 15) ) {
        my $r1fastq = $r1Hash{$headerStub};
        my ($headerr1, $sequencer1, $header2r1,$qualityr1) = split "\n", $r1fastq;
	my ($headerStubr1,$primerSampler1) = split " ", $headerr1;
	$primerSampler1 =~ s/[12]:N//;
        if( ( length($sequence) <= length($sequencer1) + $lengthWindow ) && ( length($sequence) >= length($sequencer1) - $lengthWindow ) && (length($sequencer1) > 15) ) {
	    if($primerSampler1 eq $primerSample) { #kick out any reads where both reads didn't have the same primer
		print $r1File $r1Hash{$headerStub},"\n"; 
		print $r2File $fastq,"\n";
	    }
        }
    }
}


