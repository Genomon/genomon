#!/usr/bin/perl

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

$CASAVA_CODE = $ARGV[0]; # 1: casava1.7 2: casava1.8
$IN_FASTQ = $ARGV[1];

$baseN   = "NNNNNNNNNNNNNNNNNNNN";

$qualP = "";
if ($CASAVA_CODE == 1) {
  $qualP = "%%%%%%%%%%%%%%%%%%%%"; # casava1.7 N' quality
}
else {
  $qualP = "####################"; # casava1.8 N' quality
}

open(IN, $IN_FASTQ) || die "cannot open $!";
while(<IN>) {
  chomp;
  $len = length($_);
  $padlength = 20 - $len;
  if ($padlength > 0) {
    if($. % 4 == 0) {
      print $_  . substr($qualP, 0, $padlength) . "\n";
    }
    elsif($. % 2 == 0) {
      print $_  . substr($baseN, 0, $padlength) . "\n";
    }
    else {
      print $_ . "\n";
    }
  }
  else {
    print $_ . "\n";
  }
}
close(IN);

