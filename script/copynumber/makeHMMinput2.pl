#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

use strict;
use POSIX;

my $input_fa = $ARGV[0];
my $input_as_count_bait = $ARGV[1];
my $input_NormalCount = $ARGV[2];
my $input_TumorCount = $ARGV[3];


my %bait2GC = ();
open(IN, $input_fa) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  $F[0] =~ /(chr[\dXY]+)\:(\d+)\-(\d+)/;
  my $chr = $1;
  my $start = $2;
  my $end = $3;

  my $len = length($F[1]);
  my $GC = ($F[1] =~ s/[GC|gc]//g) || 0;

  $bait2GC{$chr . "\t" . $start . "\t" . $end} = $len . "\t" . $GC;
}
close(IN);


my %bait2count_as = ();
my %bait2count_total = ();
open(IN, $input_as_count_bait) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);
  my $key = join("\t", @F[0 .. 2]);

  if ($F[3] + $F[4] > 9) {
    $bait2count_as{$key} = $F[3] . "\t" . $F[4] . "\t" . $F[5] . "\t" . $F[6];
  }
}
close(IN);


open(IN, $input_NormalCount) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_); 

  my $key = join("\t", @F[0 .. 2]);
  my $tempCount = ceil($F[3] / ($F[2] - $F[1]));
  if ($tempCount > 9) {    
    $bait2count_total{$key} = $tempCount;
  } 
}
close(IN); 


open(IN, $input_TumorCount) || die "cannot open $!";
while(<IN>) {
  s/[\r\n\"]//g;
  my @F = split("\t", $_);

  my $key = join("\t", @F[0 .. 2]);
  my $tempCount = ceil($F[3] / ($F[2] - $F[1]));
  if (exists $bait2count_total{$key}) {
    $bait2count_total{$key} = $bait2count_total{$key} . "\t" . $tempCount;
  }
}
close(IN);


foreach my $bait (sort chrpos keys %bait2count_total) {
    
  print $bait . "\t" . $bait2GC{$bait} . "\t" . $bait2count_total{$bait};
  if (exists $bait2count_as{$bait}) {

    my @F = split("\t", $bait2count_as{$bait});
    if ($#F == 3) {
      print "\t" . $bait2count_as{$bait} . "\t" . 1 . "\n";
    } else {
      print "something is wrong with bait2count.\n";
    }
  } else {
    print "\t" . join("\t", (0)x4) . "\t" . 0 . "\n";
  }
}

sub chrpos {
  my @posa = split("\t", $a);
  my @posb = split("\t", $b);

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

