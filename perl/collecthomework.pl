#!/usr/bin/perl -w

use strict;
use File::Find;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home/FAST";

#*********************************************************************************************


#collect commandline arguments



sub showUsage {

print "\nUSAGE: perl collecthomework.pl --instructor=<name> --assignment=<name> --studentfile=<filename>\n";
exit;

}


my($instructor,$assignment,$studentfile);



foreach my $item(@ARGV) {

  if ($item =~ m/--instructor=/i) {
		$instructor = substr($item,13,length($item)-13);
	}


 	if ($item =~ m/--assignment=/i) {
                $assignment = substr($item,13,length($item)-13);
        }



	if ($item =~ m/--studentfile=/i) {
                $studentfile = substr($item,14,length($item)-14);
        }

}


if (!$instructor || !$assignment || !$studentfile) {
&showUsage;
}


my($destinationRoot) = $sourceRoot . "/" . $instructor . "/homework";


my($noSubmissionYet) = "\nThe following students have not submitted homework yet:\n------------------------------------------------------------";
my($summaryLine) = "\nHomework assignments retrieved for assignment $assignment:\n-------------------------------------";


my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {

 	$_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
        my($inputLine) = $_;
        chomp ($inputLine);

        unless ($inputLine =~ /^\s*$/) {





        my(@searchFolders) = ($sourceRoot . "/" . $inputLine . "/submit");
	my(@foundProjects);

        find( sub { push @foundProjects, $File::Find::name if /$assignment/i }, @searchFolders);

	
        my($projectFile);

        foreach $projectFile(@foundProjects) {

		print "\nFound $projectFile.";

                my ($destinationFolder) = $destinationRoot . "/" . $assignment . "/" . $inputLine;
                unless (-e $destinationFolder) {
                        system ("mkdir -p $destinationFolder");
                }

                $destinationFolder = $destinationFolder . "/";
                system ("cp -f $projectFile $destinationFolder");
		$summaryLine = $summaryLine . "\n $inputLine submitted file: $projectFile";		

	}

	if (!@foundProjects) {
		$noSubmissionYet = $noSubmissionYet . "\n$inputLine";
	}


	}

}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n\n" . $noSubmissionYet . "\n\n";

print $summaryLine;