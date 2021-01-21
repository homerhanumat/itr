#!/usr/bin/perl -w

use strict;
use File::Find;
use constant TRUE => -1;
use constant FALSE => 0;
#************************ PARAMETERS *********************************************************


my($sourceRoot) = "/home/GEORGETOWNCOLLEGE.EDU";
## if you are using RStudio on Digital Ocean then there is no GEORGETOWN.EDU,
## so modify the above line to:
## my($sourceRoot) = "/home";
my($group) = "instructors";
my($permissions) = "770";
my($summaryLine);

#****************************************************************************

#return commandline arguments

sub showUsage {
  print "\nUSAGE: perl returnhomework.pl --path=<assignment>\n\n";
  exit;
}

my($dir,$destinationRoot, $inst, $file, $path);

foreach my $item(@ARGV) {
  
  if ($item =~ m/--dir=/i) {
    $dir = substr($item,6,length($item)-6);
  }
  
  if ($item =~ m/--inst=/i) {
    $inst = substr($item,7,length($item)-7);
  }
  
  if ($item =~ m/--file=/i) {
    $file = substr($item,7,length($item)-7);
  }
  
}

$path = $sourceRoot . "/" . $inst . "/" . $dir;


if (!$path ) {
  &showUsage;
}


if (!$destinationRoot) {
  $destinationRoot = $sourceRoot . "/";
}


my($INPUTFILE);
open ($INPUTFILE, "<$file") or die "Could not open $file\n";

while (<$INPUTFILE>) {
  
  $_ =~ s/\cM\cJ|\cM|\cJ/\n/g;  # Re-format Windows files
  
  my($inputLine) = $_;
  chomp ($inputLine);
  
  unless ($inputLine =~ /^\s*$/) {
    my($securityToken) = $inputLine . ":" . $group;
    my($destination) = $destinationRoot . $inputLine;
    system ("cp -rf $path $destination");
    system("chown -R $securityToken $destination");
    system ("chmod -R 770 $destination");
    $summaryLine = $summaryLine . "\n published $dir to $destination \n";		
  }
  
}

close ($INPUTFILE);
$summaryLine = $summaryLine . "\n";
print $summaryLine;