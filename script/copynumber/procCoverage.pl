#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

open(IN, $ARGV[0]) || die "cnnnot open $!";
%site2count = ();
while(<IN>) {
  s/[\r\n]//g;
  @curRow = split("\t", $_);

  $site = $curRow[0] . "\t" . $curRow[1] . "\t" . $curRow[2];
  if (exists $site2count{$site}) {
    $site2count{$site} = $site2count{$site} + $curRow[4];
  } else {
    $site2count{$site} = $curRow[4];
  }
}
close(IN);

foreach $site (sort chrpos keys %site2count) {
  print $site . "\t" . $site2count{$site} . "\n";
}

# sort accoding to chromosome and position
sub chrpos {

  @posa = split("\t", $a);
  @posb = split("\t", $b);

  $posa[0] =~ s/chr//g;
  $posb[0] =~ s/chr//g;

  $posa[0] =~ s/X/23/g;
  $posb[0] =~ s/X/23/g;

  $posa[0] =~ s/Y/24/g;
  $posb[0] =~ s/Y/24/g;

  if ($posa[0] > $posb[0]) {
    return 1;
  } elsif ($posa[0] < $posb[0]) {
    return -1;
  } else {
    if ($posa[1] > $posb[1]) {
      return 1;
    } else {
      return -1;
    }
  }
}
