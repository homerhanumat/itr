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
##	 material stripped off, a column for the section added at the end, and saved
## as a tab-delimited file.

## Second, the full file name of the output WeBWorK classlist file

## The Portal's file should be in the same directory as this script.



use 5.018;
use strict;
use utf8;


$0 =~ s|.*/||;
if (@ARGV != 2)  {
	print "\n usage: perl $0 registrar's-list outputfile\n
     e.g. perl convertGC.pl  classList.txt mat_107_a_fa_2016.lst\n\n" ;
	exit(0);
}

my ($infile, $outfile) = @ARGV;
my @classArray;
my $email;
my $copy;

$/ = chr(13);  ## set up record separator for Windows file produced by Portal (carriage return)

open(REGLIST, "$infile") || die "can't open $infile: $!\n";
open(OURLIST, ">$outfile")
    || die "can't write $outfile: $!\n";

while (<REGLIST>) {
	
	$copy = $_;
	$copy =~ s/\"//g;		## remove quotes (not a problem if it came from R)
	$copy =~ s/\r//g;   	## strip eol
									
	$copy =~ s/\t\t/\tM\t/g;	## so the empty fields (if any) get something in them
	
	## the following was for debugging:
	# my $copy2 = $copy;
	# $copy2 =~ s/([^\x20-\x7E])/sprintf '\x{%02x}', ord $1/eg;
	# print ":$copy2:\n"; 
	
    my @regArray=split(/\t/, $copy);	## get fields from registrar's file

    foreach (@regArray) {		## clean 'em up!
	($_) = m/^\s*(.*?)\s*$/; 	## (remove leading and trailing spaces)}
	}  

  ## extract the relevant fields

   my($ferpa, $id, $name, $status, $waitlist,
      $login, $crosslist, $major, $classrank, $section )
     = @regArray;

	## Hack.  The login comes as a complete email address.  Remove the @ and following symbols.

	$login =~ s/@.*//;

  ## massage the data a bit

    my($lname, $fname) = ($name =~ /^(.*),\s*(.*)$/);
    if ($login =~/\w/) {$email = "$login".'@georgetowncollege.edu';}
    else
		{
		$email= " ";
		$login = $id;
	}
	
	$status = 'C'; # assuming all students are registered
	
  ## dump it in our classArray format
  ## At present only $id, $lname, $fname, $status, $email, $section, $recitation and $login are used by WeBWorK

    @classArray=(	$id,		## used as initial password
					$lname,
					$fname,
					$status,
					' ',		## comment
					$section,
					' ',		## recitation
					$email,
					$login		## this is user_id
					);
					

  ## and print that sucker!

    print OURLIST join(',', @classArray) , "\n";
}
  close(OURLIST);
  close(REGLIST);

  ## arrange the columns nicely

   &columnPrint("$outfile","$outfile");  ## appears to have no effects on files forom Windows
   
   
   
sub columnPrint {

# Takes two parameters.  The first is the filename of the
# delimited input file.  The second is the name of the
# output file (these names may be the same).  The permissions
# and group of the output file will be the same as the
# input file

# Takes any delimited (with \$DELIM delimiters) file and adds
# extra space if necessary to the fields so that all columns line up.
# The widest field in any column will contain exactly 2 spaces at the
# end of the (non space characters 0f the) field. For example
# ",a very long field entry  ," at one extreme and  ",  ," at the other
#
    my($inFileName,$outFileName)=@_;
    my($line);

    my ($permission, $gid) = (stat($inFileName))[2,5];
    $permission =  ($permission & 0777);    ##get rid of file type stuff

    open(INFILE,"$inFileName") or wwerror("$0","can't open $inFileName for reading");
    my @inFile=<INFILE>;
    close(INFILE);

    &createFile($outFileName, $permission, $gid);

    my @outFile = &columnArrayArrange(@inFile);

    open(OUTFILE,">$outFileName")   or wwerror("$0","can't open $outFileName for writing");
    foreach $line (@outFile) {print OUTFILE $line;}
    close(OUTFILE);
}
   
sub columnArrayArrange  {

## takes as a parameter a delimited array
## (such as you would get by reading in a delimited file)
## where each element is a line from a delimited file.

# Outputs an array which adds
# extra space if necessary to the fields so that all columns line up.
# The widest field in any column will contain exactly 1 spaces at the
# end of the (non space characters of the) field. For example
# ",a very long field entry ," at one extreme and  ", ," at the other

    my @inFile=@_;
    my($i,$tempFileName,$datString,$line);
    my @outFile =();
    my(@fieldLength,@datArray);
    $i=1;

    @fieldLength=&getFieldLengths(\@inFile);
    foreach $line (@inFile)   {    ## read through file array and get field lengths
        unless ($line =~ /\S/)  {next;}    ## skip blank lines
        chomp $line;
        @datArray=&getRecord($line);
        for ($i=0; $i <=$#datArray; $i++) {
            $datArray[$i].=(" " x ($fieldLength[$i]+1-length("$datArray[$i]")));
        }
        $datString=join(',',@datArray);
        push @outFile , "$datString\n";
    }
    @outFile;
}

sub createFile {
    my ($fileName, $permission, $numgid) = @_;

    open(TEMPCREATEFILE, ">$fileName") ||
      warn " Can't open $fileName";
    my @stat = stat TEMPCREATEFILE;
    close(TEMPCREATEFILE);

    ## if the owner of the file is running this script (e.g. when the file is first created)
    ## set the permissions and group correctly
    if ($< == $stat[4]) {
        my $tmp = chmod($permission,$fileName) or
          warn "Can't do chmod($permission, $fileName)";
        chown(-1,$numgid,$fileName)  or
          warn "Can't do chown($numgid, $fileName)";
    }
}

sub getFieldLengths {

    ## takes as a parameter the  reference to a delimited array
    ## (such as you would get by reading in a delimited file)
    ## where each element is a line from a delimited file.
    ## returns an array which holds
    ## the maximum field lengths in the file.

    my ($datFileArray_ref)=@_;
    my($i);
    my(@datArray,@fieldLength,@datFileArray, $line);
    @fieldLength=();
    @datFileArray=@$datFileArray_ref;

    foreach $line (@datFileArray)   {    ## read through file and get field lengths
        unless ($line =~ /\S/)  {next;}  ## skip blank lines
        chomp $line;
        @datArray=&getRecord($line);
        for ($i=0; $i <=$#datArray; $i++) {
            $fieldLength[$i] = 0 unless defined $fieldLength[$i];
            $fieldLength[$i]=&max(length("$datArray[$i]"),$fieldLength[$i]);
        }
    }
    return (@fieldLength);
}



sub getRecord

        #       Takes a delimited line as a parameter and returns an
        #       array.  Note that all white space is removed.  If the
        #       last field is empty, the last element of the returned
        #       array is also empty (unlike what the perl split command
        #       would return).  E.G. @lineArray=&getRecord(\$delimitedLine).
        {
    my $DELIM = ',';
        my($line) = $_[0];
        my(@lineArray);
        $line.='A';                                     # add 'A' to end of line so that
                                                        # last field is never empty
        @lineArray = split(/\s*${DELIM}\s*/,$line);
        $lineArray[$#lineArray] =~s/\s*A$//;            # remove spaces and the 'A' from last element
        $lineArray[0] =~s/^\s*//;                       # remove white space from first element
        @lineArray;
        }
sub max  {  ## find the max element of array
    my $out = $_[0];
    my $num;
    foreach $num (@_) {
        if ((defined $num) and ($num > $out)) {$out = $num;}
    }
    $out;
}