#!/usr/bin/perl
#$ -S /usr/bin/perl
#$ -cwd

#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use Fcntl;

$infile = $ARGV[0];
$outfile = $ARGV[1];

open(INPUT,$infile) || die "can't open $infile";
open(OUT,">$outfile") || die "can't open $outfile";
while(<INPUT>){
  chomp;
  $line = $_;
  @linelist = split(/\t/,$line);
	
  foreach my $value (@linelist) {
    @valuelist = split(/:/,$value);
    if ($valuelist[0] eq "ID") {
      print OUT $valuelist[1] ."\n"
    }
  }
}
close(INPUT);
close(OUT);

