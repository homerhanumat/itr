#!/usr/bin/perl -w

use strict;
use Crypt::RC4;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************

my($sourceRoot) = "/home";
my($group) = "instructors";
my($permissions) = "770";

#*********************************************************************************************


#createdirectories commandline arguments



sub showUsage {
  
  print "\nUSAGE: perl createdirectories.pl --studentfile=<filename>\n\n";
  exit;
  
}


my($studentfile,$summaryLine,$userDirective);

foreach my $item(@ARGV) {
 if ($item =~ m/--studentfile=/i) {
    $studentfile = substr($item,14,length($item)-14);
  }
}



if (!$studentfile) {
  &showUsage;
}




$summaryLine = "\nDirectory Permission Updates:\n--------------------------\n\n";



my($INPUTFILE);
open ($INPUTFILE, "<$studentfile") or die "Could not open $studentfile\n";

while (<$INPUTFILE>) {
  
  $_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
  my($inputLine) = $_;
  chomp ($inputLine);
  
  unless ($inputLine =~ /^\s*$/) {
    
    
    my($submitPath) = $sourceRoot . "/" . $inputLine . "/submit";
    my($returnPath) = $sourceRoot . "/"  . $inputLine . "/returned";
    my($mynotesPath) = $sourceRoot . "/"  . $inputLine ."/mynotes";
    
    unless (-e $submitPath) { 
      system ("mkdir $submitPath"); #or die "\nCould not create directory $submitPath.\n"; 
      $summaryLine = $summaryLine . "\nCreated submit path $submitPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nSubmit path $submitPath for user $inputLine already exists.\n";
    }
    
    unless (-e $returnPath) { 
      system ("sudo mkdir $returnPath");  #or die "\nCould not create directory $returnPath.\n"; 
      $summaryLine = $summaryLine . "\nCreated return path $returnPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nReturn path $returnPath for user $inputLine already exists.\n";
    }
    
    unless (-e $mynotesPath) {
      system ("sudo mkdir $mynotesPath");  #or die "\nCould not create directory $returnPath.\n";
      $summaryLine = $summaryLine . "\nCreated mynotes path $mynotesPath for user $inputLine.\n";
    } else {
      $summaryLine = $summaryLine . "\nmynotes path $mynotesPath for user $inputLine already exists.\n";
    }
    
    
    my($securityToken) = $inputLine . ":" . $group;
    
    system("sudo chown $securityToken $submitPath");
    $summaryLine = $summaryLine . "\nChanged ownership of submit path $submitPath to $securityToken.\n";
    
    system("chown $securityToken $returnPath");
    $summaryLine = $summaryLine . "\nChanged ownership of return path $returnPath to $securityToken.\n";
    
    system("chown $securityToken $mynotesPath");
    $summaryLine = $summaryLine . "\nChanged ownership of mynotes path $mynotesPath to $securityToken.\n";
    
    
    system("chmod $permissions $submitPath");
    $summaryLine = $summaryLine . "\nChanged permissions of submit path $submitPath to $permissions.\n";
    
    system("sudo chmod $permissions $returnPath");
    $summaryLine = $summaryLine . "\nChanged permissions of return path $returnPath to $permissions.\n";
    
    system("sudo chmod $permissions $mynotesPath");
    $summaryLine = $summaryLine . "\nChanged permissions of mynotes path $mynotesPath to $permissions.\n";
    
    
  }
  
}

close ($INPUTFILE);

$summaryLine = $summaryLine . "\n";

print $summaryLine;