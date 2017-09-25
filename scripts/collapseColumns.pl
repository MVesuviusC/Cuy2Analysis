#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

##############################
# By Matt Cannon
# Date: 12/1/16
# Last modified: 12/1/16
# Title: collapseColumns.pl
# Purpose: Given a column that contains a unique identifier, collapse all other columns, 
#          concatenating them with a symbol
##############################

##############################
# Options
##############################


my $verbose;
my $help;
my $input;
my $uniqueColumn;
my $collapseString = ",";

# i = integer, s = string
GetOptions ("verbose"           => \$verbose,
            "help"              => \$help,
            "input=s"=> \$input,
            "uniqueColumn=i"=> \$uniqueColumn,
            "collapseString=s"=> \$collapseString
      )
    or pod2usage(0) && exit;

pod2usage(1) && exit if ($help);


##############################
# Global variables
##############################
my %storageHash;

##############################
# Code
##############################

##############################
### decrement uniqueColumn to make 0-based
$uniqueColumn--;

##############################
### Make sure uniqueColumn is specified
if($uniqueColumn eq "") {
    die "You must specify uniqueColumn\n";
}

##############################
### Fill up %storageHash with the data
open (INPUT, "<", $input) or die "Cannot open input file\n";
while(my $line = <INPUT>){
    chomp $line;
    my @columns = split "\t", $line;
    for(my $i = 0; $i < scalar(@columns); $i++) {
        push @{ $storageHash{$columns[$uniqueColumn]}[$i] }, $columns[$i];
    }
}

##############################
### Go through %storageHash and collapse the identical 
for my $key (keys %storageHash) {
    print $key;
    for(my $i = 0; $i < scalar(@{ $storageHash{$key} }); $i++) {
        if($i != $uniqueColumn) {
	    my @newArray = uniqueArray(@{ $storageHash{$key}[$i]});
	    print "\t", join($collapseString, @newArray),
	}
    }
    print "\n";
}



##############################
# Subfunctions
##############################
sub uniqueArray {
    my @inputArray = @_;
    my @outputArray;
    my %knownHash;
    for my $element (@inputArray) {
        if(!exists($knownHash{$element})) {
            push @outputArray, $element;
            $knownHash{$element} = 1;
        }
    }
    return @outputArray;
}

##############################
# POD
##############################

#=pod

=head SYNOPSIS

Summary:

    .pl - generates a consensus for a specified gene in a specified taxa

Usage:

    perl .pl [options]


=head OPTIONS

Options:

    --verbose
    --help

=cut

