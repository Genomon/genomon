#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use List::Util qw(max);

# check wheter input quality threshoold is appropriate or not.
$thres = $ARGV[0];
if ($thres < 0 or $thres > 40) {
	die "input qualith threshould is not appropriate.$!";
}

# prepare quality strings to be removed 
$filterQuals = "";
for ($i = 33; $i < 33 + $thres; $i++) {
  $filterQuals .= chr($i);
}
print $filterQuals . "\n";


open(IN, $ARGV[1]) || die "cannot open $!";

open(OUT1, ">" . $ARGV[2]) || die "cannot open $!";
open(OUT2, ">" . $ARGV[3]) || die "cannot open $!";
open(OUT3, ">" . $ARGV[4]) || die "cannot open $!";

print OUT1 "chr" . "\t" . "pos" . "\t" . "ref" . "\t" . "depth" . "\t" . "A" . "\t" . "a" . "\t" . "C" . "\t" . "c" . "\t" . "G" . "\t". "g" . "\t" . "T" . "\t" . "t" . "\n";

$ID2bases = ();
while(<IN>) {
  s/[\r\n]//g;
  @curRow = split("\t", $_);

  %insertion_p = ();
  %insertion_n = ();
  %deletion_p = ();
  %deletion_n = ();

  $depth = $curRow[3]; 
    
  if ($depth > 0) {
    # remove insertion and deletion
    while($curRow[4] =~ m/\+([0-9]+)/g) {

      $num = $1;
      $site = pos $curRow[4];
      $var = substr($curRow[4], $site, $num);
		
      $strand = "1";
      if ($var =~ tr/[acgt]/[ACGT]/) {
        $strand = "-1";
      }

      $key = join("\t", @curRow[0 .. 3]) . "\t" . $var;

      if (exists $insertion_p{$key} or exists $insertion_n{$key}) {

        if ($strand == "1") {
          $insertion_p{$key} = $insertion_p{$key} + 1;
        } else {
          $insertion_n{$key} = $insertion_n{$key} + 1;
        }
      } else {
        if ($strand == "1") {
          $insertion_p{$key} = 1;
          $insertion_n{$key} = 0;
        } else {
          $insertion_p{$key} = 0;
          $insertion_n{$key} = 1;
        }
      }

      substr($curRow[4], $site - length($num) - 1, $num + length($num) + 1, "");
    }

    while($curRow[4] =~ m/\-([0-9]+)/g) {
      $num = $1;
      $site = pos($curRow[4]);
      $var = substr($curRow[4], $site, $num);

      $strand = "1";
      if ($var =~ tr/[acgt]/[ACGT]/) {
        $strand = "-1";
      }

      $key = join("\t", @curRow[0 .. 3]) . "\t" . $var;
		
      if (exists $deletion_p{$key} or exists $deletion_n{$key}) {

        if ($strand == "1") {
          $deletion_p{$key} = $deletion_p{$key} + 1;
        } else {
          $deletion_n{$key} = $deletion_n{$key} + 1;
        }
      } else {
        if ($strand == "1") {
          $deletion_p{$key} = 1;
          $deletion_n{$key} = 0;
        } else {
          $deletion_p{$key} = 0;
          $deletion_n{$key} = 1;
        }
      }

      substr($curRow[4], $site - length($num) - 1, $num + length($num) + 1, "");
    }

    # remove start marks!
    $curRow[4] =~ s/\^.//g;

    # remove end marks!
    $curRow[4] =~ s/\$//g;

    # for debugging !!
    if (length($curRow[4]) != length($curRow[5])) {
      print "something is wrong!!!\n";
      print length($curRow[4]) . "\t" . length($curRow[5]) . "\n";
    }

    $uref  = uc($curRow[2]);
    $lref  = lc($curRow[2]);
    $curRow[4] =~ s/\./$uref/g;
    $curRow[4] =~ s/,/$lref/g;

    %base2qual = ();
    $base2qual{"A"} = "";
    $base2qual{"C"} = "";
    $base2qual{"G"} = "";
    $base2qual{"T"} = "";
    $base2qual{"a"} = "";
    $base2qual{"c"} = "";
    $base2qual{"g"} = "";
    $base2qual{"t"} = "";

    @bases = split("", $curRow[4]);
    @quals = split("", $curRow[5]);
    for ($ii = 0; $ii <= $#bases; $ii++) {
      $base2qual{$bases[$ii]} .= $quals[$ii];
    }

    foreach $base (keys %base2qual) {
      $base2qual{$base} =~ s/[$filterQuals]//g;
    }

    print OUT1 join("\t", @curRow[0 .. 3]) . "\t";
    print OUT1 length($base2qual{"A"}) . "\t" . length($base2qual{"a"}) . "\t" . length($base2qual{"C"}) . "\t" . length($base2qual{"c"}) . "\t";
    print OUT1 length($base2qual{"G"}) . "\t" . length($base2qual{"g"}) . "\t" . length($base2qual{"T"}) . "\t" . length($base2qual{"t"}) . "\n";

    foreach $ins (keys %insertion_p) {
      print OUT2 $ins . "\t" . $insertion_p{$ins} . "\t" . $insertion_n{$ins} . "\n";
    }
    foreach $del (keys %deletion_p) {
      print OUT3 $del . "\t" . $deletion_p{$del} . "\t" . $deletion_n{$del} . "\n";
    }
  }
}
close(IN);
