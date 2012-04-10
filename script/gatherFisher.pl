#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use List::Util qw(max);

$mutaitonFile = $ARGV[0];
$insertionFile = $ARGV[1];
$deletionFile = $ARGV[2];


if (-e $mutaitonFile) { 
  open(IN, $mutaitonFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);
 
    $ref = $curRow[2];
    $mis = $curRow[3];
    $depth = $curRow[4];
    $bases = join(",", @curRow[5 .. 8]);

    print $curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[1] . "\t". $ref . "\t" . $mis . "\t" . $depth . "\t" . $bases . "\t" . join("\t", @curRow[9 .. 13]) . "\n";
  }
  close(IN);
}


if (-e $insertionFile) { 
  open(IN, $insertionFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);

    $ref = $curRow[3];
    $mis = $curRow[4];
    $bases = join(",", @curRow[5 .. 6]);

    print $curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[2] . "\t". $ref . "\t" . $mis . "\t" . $curRow[5] . "\t" . $bases . "\t" . join("\t",     @curRow[7 .. 11]) . "\n";
  }
  close(IN);
}

if ( -e $deletionFile) { 
  open(IN, $deletionFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);

    $ref = $curRow[3];
    $mis = $curRow[4];
    $bases = join(",", @curRow[5 .. 6]);

    print $curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[2] . "\t". $ref . "\t" . $mis . "\t" . $curRow[5] . "\t" . $bases . "\t" . join("\t",     @curRow[7 .. 11]) . "\n";
  }
  close(IN);
}

