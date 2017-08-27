#!/usr/bin/perl -w

use strict;
use File::Find;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home/GEORGETOWNCOLLEGE.EDU";
my($group) = "instructors";
my($permissions) = "770";
## if you are using RStudio on Digital Ocean then then there is no GEORGETOWNCOLLEGE.EDU,
## so modify the above line to:
## my($sourceRoot) = "/home";

#*********************************************************************************************


#collect commandline arguments



sub showUsage {

print "\nUSAGE: perl collecthomework.pl --inst=<name> --assign=<name> --file=<filename>\n";
exit;

}


my($inst,$assign,$file);



foreach my $item(@ARGV) {

  if ($item =~ m/--inst=/i) {
		$inst = substr($item,7,length($item)-7);
	}


 	if ($item =~ m/--assign=/i) {
                $assign = substr($item,9,length($item)-9);
        }



	if ($item =~ m/--file=/i) {
                $file = substr($item,7,length($item)-7);
        }

}


if (!$inst || !$assign || !$file) {
&showUsage;
}


my($destinationRoot) = $sourceRoot . "/" . $inst . "/homework";


my($noSubmissionYet) = "\nThe following students have not submitted homework yet:\n------------------------------------------------------------";
my($summaryLine) = "\nHomework assignments retrieved for assignment $assign:\n-------------------------------------";


my($INPUTFILE);
open ($INPUTFILE, "<$file") or die "Could not open $file\n";

while (<$INPUTFILE>) {

 	$_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
        my($inputLine) = $_;
        chomp ($inputLine);

        unless ($inputLine =~ /^\s*$/) {



        my($studentHome) = ($sourceRoot . "/" . $inputLine);
        my($securityToken) = $inputLine . ":" . $group;
        system("sudo chown -R $securityToken" $studentHome");
        $summaryLine = "Changed ownership of path $studentHome to $securityToken.\n";
        system("sudo chmod -R $permissions $studentHome");
        $summaryLine = "Changed permissions of path $studentHome to $permissions.\n";

        my(@searchFolders) = ($sourceRoot . "/" . $inputLine . "/submit");
	my(@foundProjects);

        find( sub { push @foundProjects, $File::Find::name if /$assign/i }, @searchFolders);

	
        my($projectFile);

        foreach $projectFile(@foundProjects) {

		print "\nFound $projectFile.";

                my ($destinationFolder) = $destinationRoot . "/" . $assign . "/" . $inputLine;
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