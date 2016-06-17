#!/usr/bin/perl -w

use strict;
use File::Find;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home/FAST";
my($group) = "instructors";
my($permissions) = "770";

my($instructor) = "homer";
my($studentfile) = "students.txt";
my($flag) = "_com";

#*********************************************************************************************


#return commandline arguments



sub showUsage {

print "\nUSAGE: perl returnhomework.pl --path=<assignment>\n\n";
exit;

}


my($path,$destinationRoot);



foreach my $item(@ARGV) {


   if ($item =~ m/--path=/i) {
                $path = substr($item,7,length($item)-7);
        }

}

$path = $sourceRoot . "/" . $instructor . "/" . "homework/" . $path . "/";



if (!$path ) {
&showUsage;
}


unless ( $path =~ s|/\s*$|/| ) 
{
    $path = $path . "/";
}


if (!$destinationRoot) {
	$destinationRoot = $sourceRoot . "/";
}

my($summaryLine) = "\nHomework graded in folder $path:\n-------------------------------------";


my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {

 	$_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
        my($inputLine) = $_;
        chomp ($inputLine);

        unless ($inputLine =~ /^\s*$/) {



        my(@searchFolders) = ($path .  $inputLine);
	my(@foundProjects);

        find( sub { push @foundProjects, $File::Find::name if /$flag/i }, @searchFolders);

	
        my($projectFile);

        foreach $projectFile(@foundProjects) {

		print "\nFound $projectFile.";

                my ($destinationFolder) = $destinationRoot . $inputLine . "/returned";
                unless (-e $destinationFolder) {
                        system ("mkdir -p $destinationFolder");
                }

                $destinationFolder = $destinationFolder . "/";

 		my($securityToken) = $inputLine . ":" . $group;
        	
                system ("cp -f $projectFile $destinationFolder");
		
		my($folderWildcard) = $destinationFolder . "*";
	

    system("chown $securityToken $folderWildcard");
    system ("chmod 770 $folderWildcard");


		
		$summaryLine = $summaryLine . "\n $inputLine returned $projectFile to $destinationFolder\n";		


	}


	}

}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n";

print $summaryLine;