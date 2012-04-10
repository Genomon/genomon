#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


$mutationFile = $ARGV[0];
$insersionFile = $ARGV[1];
$deletionFile = $ARGV[2];

# mutation
if (-e $mutationFile) { 
  open(IN, $mutationFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);
   
    $chr = $curRow[0];
    $pos = $curRow[1];
    $ref = $curRow[2];
    $mis = $curRow[3];

    $bases_t = join(",", @curRow[5 .. 8]);
    $bases_n = join(",", @curRow[12 .. 15]); 

    print $chr . "\t" . $pos . "\t" . $pos . "\t" . $ref . "\t" . $mis . "\t" . $bases_t . "\t" . $bases_n . "\t" . $curRow[9] . "\t" . $curRow[10] . "\t" . $curRow[16] . "\t" . $curRow[17] . "\t" . $curRow[18] . "\n";
  }
}


# insertion
if (-e $insersionFile) { 
  open(IN, $insersionFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);

    $chr = $curRow[0];
    $pos1 = $curRow[1];
    $pos2 = $curRow[2];
    $ref = $curRow[3];
    $mis = $curRow[4];

    $bases_t = join(",", @curRow[5 .. 6]);
    $bases_n = join(",", @curRow[9 .. 10]);

    print $chr . "\t" . $pos1 . "\t" . $pos2 . "\t" . $ref . "\t" . $mis . "\t" . $bases_t . "\t" . $bases_n . "\t" . $curRow[7] . "\t" . $curRow[8] . "\t" . $curRow[11] . "\t" . $curRow[12] . "\t" . $curRow[13] . "\n";
  }
}

# deletion 
if (-e $deletionFile) { 
  open(IN, $deletionFile) || die "cannot open $!";
  while(<IN>) {
    s/[\r\n\"]//g;
    @curRow = split("\t", $_);

    $chr = $curRow[0];
    $pos1 = $curRow[1];
    $pos2 = $curRow[2];
    $ref = $curRow[3];
    $mis = $curRow[4];

    $bases_t = join(",", @curRow[5 .. 6]);
    $bases_n = join(",", @curRow[9 .. 10]);

    print $chr . "\t" . $pos1 . "\t" . $pos2 . "\t" . $ref . "\t" . $mis . "\t" . $bases_t . "\t" . $bases_n . "\t" . $curRow[7] . "\t" . $curRow[8] . "\t" . $curRow[11] . "\t" . $curRow[12] . "\t" . $curRow[13] . "\n";
  }
}    
