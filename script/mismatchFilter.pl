#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

$MAX_INDEL = $ARGV[1];

open(IN, $ARGV[0]) || die "ccannot open $!";
while(<IN>) {
  s/[\r\n]//g;
  $key = $_;

  # if the record is header, print it.
  if ($key =~ /^@/) {
    print $key . "\n";
  } else {
    @curRow = split("\t", $key);

    # get the edit distance to the reference
    $NM = 0;
    if ($key =~ /NM:i:(\d+)/) {
      $NM = $1;
    }

    # get the numbers of deletions and insertions, respectively
    $num_D = ($curRow[5] =~ s/D/D/g);
    $num_I = ($curRow[5] =~ s/I/I/g);

    # if the number of deletions or insertions is less than two,
    if ( ($num_D + $num_I) < $MAX_INDEL) {

      $size_D = 0;
      if ($curRow[5] =~ /(\d+)D/) {
        $size_D = $1;
      }

      $size_I = 0;
      if ($curRow[5] =~ /(\d+)I/) {
        $size_I = $1;
      }
   
      # if the edit distance minus the number of bases in deletion and insertion ( which I define is the number of mismatch ??), print the record.
      if ( ($NM - $size_D - $size_I) < 5) {
        print join("\t", @curRow) . "\n";
      }
    }
  }
}
close(IN);

    
    
