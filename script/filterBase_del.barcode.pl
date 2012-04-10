#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use List::Util qw(max);



open(IN, $ARGV[0]) || die "cannot open $!";
while(<IN>) {

  s/[\r\n]//g;
  @curRow = split("\t", $_);

  $depth = $curRow[3]; 
    
  if ($depth > 9) {

    $start = $curRow[1] + 1;
    $end = $curRow[1] + length($curRow[4]);

    $misNum = $curRow[5] + $curRow[6];
    $misRate = ($misNum / $depth);

    if ($misRate > 0.07) {

      # ratio of mismatch bases in each strand
      $sratio = $curRow[5] / ($curRow[5] + $curRow[6]);
            	
      print $curRow[0] . "\t" . $start . "\t" . $end . "\t" . $curRow[4] . "\t" . "-" . "\t" . $depth . "\t" . $misNum . "\t"  . $misRate . "\t" . $sratio . "\n";
    }
  }
}
close(IN);

