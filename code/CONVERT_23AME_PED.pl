#!/usr/bin/perl
#From https://github.com/razibkkhan/RazibKhanDataCode

use strict;
use warnings;
# file and ped file format stuff passed in
my($file,$individualID,$familyID,$patID,$matID,$sex,$phen)=@ARGV;

# make sure vars are passed correctly
if(scalar(@ARGV)  == 0){
  print "\nParameters need to be passed for the script to work: CONVERT_23AME_PED.pl genome.txt MyID MyFamID\n";
  print "Please pass parameters into the script of the following form:\n\n";
  print "File name: required\n";
  print "Individual ID: optional, if not provided will be set to ID001\n";
  print "Family ID:  optional, if not provided will be set to FAM001\n";
  print "Paternal ID: if not provided will be set to unknown\n";
  print "Maternal ID: if not provided will be set to unknown\n";
  print "Sex: 1 = male, 2 = female, if not provided will be set to unknown\n";
  print "Phenotype: 1, or 2, if not set will be set to -9\n\n";
  
}#END IF
else{
  # set default bars if needed
  if(!$individualID){
    $individualID = "ID001";
  }
  if(!$familyID){
    $familyID = "FAM001";
  }
  if(!$patID){
    $patID = "unknown";
  }
  if(!$matID){
    $matID = "unknown";
  }
  if(!$sex){
    $sex = "unknown";
  }
  if(!$phen){
    $phen = "-9";
  }
  # make sure file exists
  if (-e $file)
  {
    # stuff before the genotypes
    my $initialSegment = "$familyID\t$individualID\t$patID\t$matID\t$sex\t$phen";
    # now add genotype info
    makePED($file,$initialSegment)
  }
  else
  {
    print "\nPlease enter a file name which exists\n\n";
  }  
}# do stuff

 

sub makePED{
  my $rawfilein = shift;
  my $presection = shift;
  open(RAWDATA, "<", "$rawfilein") or die $!;
  # split
  my @splitfile = split(/\./,$rawfilein);
  my $rawfile = $splitfile[0];  

  open(MAP, ">", $rawfile.".map") or die $!;
  open (PED, ">", $rawfile.".ped") or die $!;

  my @line;
  my @genotype;

  print PED $presection;

  while(my $this_line = <RAWDATA>) {
    if($this_line =~ /^rs/){
    @line = split('\t', $this_line);
    @genotype = unpack('aa', $line[3]);
    if($line[1]=~ /^[+-]?\d+$/){

    if ($line[1] >=1 && $line[1] <= 22){        
      if ($genotype[0] eq '-' or $genotype[0] eq 'I' or $genotype[0] eq 'D') 
	{ 
	  @genotype = unpack('aa', "00"); 
	}
      print MAP "$line[1] $line[0] 0 $line[2]\n";
      print PED "\t$genotype[0] $genotype[1]";
      }
    }
  }
}
  close PED;
  close MAP;
  close RAWDATA;
}