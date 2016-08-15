#!/usr/bin/perl
################################################################################
# WeBWorK Online Homework Delivery System
# Copyright � 2000-2007 The WeBWorK Project, http://openwebwork.sf.net/
# $CVSHeader: webwork2/bin/readURClassList.pl,v 1.2.2.1 2007/08/13 22:53:39 sh0$
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of either: (a) the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any later
# version, or (b) the "Artistic License" which comes with this package.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See either the GNU General Public License or the
# Artistic License for more details.
################################################################################

## convertGC
##
## This is a specific routine for reading class lists which comes from the Portal
## at Georgetown College and producing a classlist file usable by WeBWorK

## It is modified from a script written for the University of Rochester.

## IT IS ASSUMED THAT THE INPUT FILE IS DELIMITED WITH TABS (\t).

## Takes two parameters.

## First, the full file name of the Portal's class list file with the header
##	 material stripped off.  The section should be added at the end.

## Second, the full file name of the output WeBWorK classlist file

## Note:  currently we have to pre-process the file through R in order
##    to get this script to work.


use 5.018;
use strict;
use utf8;
use lib '/Users/homer/perl5/perlbrew/perls/perl-5.24.0/lib/site_perl/5.24.0';
use Spreadsheet::Read;


$0 =~ s|.*/||;
if (@ARGV != 2)  {
	print "\n usage: $0 registrar's-list outputfile\n
     e.g. convertGC.pl  ClassRoster.txt mth140A.lst\n\n" ;
	exit(0);
}

my ($infile, $outfile) = @ARGV;



my $book = ReadData ('classList.xlsx');

my @rows = Spreadsheet::Read::rows($book->[1]);
foreach my $i (1 .. scalar @rows) {
    foreach my $j (1 .. scalar @{$rows[$i-1]}) {
        say chr(64+$i) . " $j " . ($rows[$i-1][$j-1] // '');
    }
}