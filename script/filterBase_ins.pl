#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use List::Util qw(max);

%basesPosHashTumor;

open(IN, $ARGV[0]) || die "cannot open $!";
%ID2bases_tum = ();
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
            	
      $ID2bases_tum{$curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[4]} = "-" . "\t" . $curRow[4] . "\t" . $depth . "\t" . $misNum . "\t"  . $misRate . "\t" . $sratio;

      $basePosKey = $curRow[0] . "\t" . $curRow[1]; 
      $basesPosHashTumor{$basePosKey} = "1";
    }
  }
}
close(IN);


open(IN, $ARGV[1]) || die "cannot open $!";
%ID2bases_nor = ();
while(<IN>) {

  s/[\r\n]//g;
  @curRow = split("\t", $_);

  $depth = $curRow[3];

  $start = $curRow[1] + 1;
  $end = $curRow[1] + length($curRow[4]);

  $misNum = $curRow[5] + $curRow[6];
  $misRate = ($misNum / $depth);

  # ratio of mismatch bases in each strand
  $sratio = $curRow[5] / ($curRow[5] + $curRow[6]);

  $ID2bases_nor{$curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[4]} = "-" . "\t" . $curRow[4] . "\t" . $depth . "\t" . $misNum . "\t"  . $misRate . "\t" . $sratio;

}
close(IN);


# get depth for each position
open(IN, $ARGV[2]) || die "cannot open $!";
%ID2depth = ();
while(<IN>) {
  s/[\r\n]//g;
  @curRow = split("\t", $_);

  $basePosKey = $curRow[0] . "\t" . $curRow[1];
  if ($basesPosHashTumor{$basePosKey} eq "1") { 
    $ID2depth{$curRow[0] . "\t" . $curRow[1]} = $curRow[3];       
  }
}
close(IN);


while(($ID, $value) = each(%ID2bases_tum)) { 

  @curRow1 = split("\t", $ID);
  @curRow2 = split("\t", $value);

  $tmisRate = $curRow2[4];
  $tdepth = $curRow2[2];
  $ndepth = $ID2depth{$curRow1[0] . "\t" . $curRow1[1]};
    
  if ($tdepth > 9 and $ndepth > 9 and $tmisRate > 0.07) {

    $chr = $curRow1[0];
    $pos = $curRow1[1];

    $tmisNum = $curRow2[3];
    $insSeq = $curRow2[1];
    $tsratio = $curRow2[5];

    $nmisNum = 0;
    $nmisRate = 0;
    $nsratio = "---";

    if (exists $ID2bases_nor{$ID}) {

      @curRow3 = split("\t", $ID2bases_nor{$ID});
      $nmisNum = $curRow3[3];
      $nmisRate = $curRow3[4];
      $nsratio = $curRow3[5];
    }

    print $chr . "\t" . $pos . "\t" . $pos . "\t" . "-" . "\t" . $insSeq . "\t" . $tdepth . "\t" . $tmisNum . "\t" . $tmisRate . "\t" . $tsratio . "\t" . $ndepth . "\t" . $nmisNum . "\t" . $nmisRate . "\t" . $nsratio . "\n";
  }
}

