#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

open(IN, $ARGV[0]) || die "cannot open $!";

$num = 1;
while(<IN>) {
  s/[\r\n\"]//g;
  @curRow = split("\t", $_);

  $chr = $curRow[0];
  $pos = $curRow[1];
  $ref = $curRow[2];
  $ref =~ tr/a-z/A-Z/;
  $alt = $curRow[3];
  $alt =~ tr/a-z/A-Z/;
  
  if ($ref eq "N") {
    next;
  }
    
  if ($ref eq "A") {
    $ind1 = 0;
  } elsif ($ref eq "C") {
    $ind1 = 1;
  } elsif ($ref eq "G") {
    $ind1 = 2;
  } elsif ($ref eq "T") {
    $ind1 = 3;
  } else {
    print "something is wrong with reference allele! : " . $curRow[2] ."\n";
  }

  if ($alt eq "A") {
    $ind2 = 0;
  } elsif ($alt eq "C") {
    $ind2 = 1;
  } elsif ($alt eq "G") {
    $ind2 = 2;
  } elsif ($alt eq "T") {
    $ind2= 3;
  } else {
    print "something is wrong with alternate allele! : " . $curRow[3] ."\n";
  }

  $ppos = $pos - 1;

  $site2num_normal{$chr . "\t" . $ppos . "\t" . $pos . "\t" . $curRow[2] . "\t" . $curRow[3]} = $curRow[5 + $ind1] . "\t" . $curRow[5 + $ind2];
  $site2num_tumor{$chr . "\t" . $ppos . "\t" . $pos . "\t" . $curRow[2] . "\t" . $curRow[3]} = $curRow[12 + $ind1] . "\t" . $curRow[12 + $ind2];

  $num = $num + 1;
}
close(IN);


foreach $key (sort chrpos keys %site2num_normal) {
  @pos = split("\t", $key);
  print join("\t", @pos) . "\t" . $site2num_normal{$key} . "\t" . $site2num_tumor{$key} . "\n";
}


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


