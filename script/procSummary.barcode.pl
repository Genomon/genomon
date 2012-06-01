open(IN, $ARGV[0]) || die "cannot open $!";
$_ = <IN>;
s/[\r\n]//g;
@curRow = split("\t", $_);

print join("\t", @curRow[0 .. $#curRow - 1]) . "\t" .  "bases" . "\t" . "mismatch-ratio" . "\t" . "strand ratio" . "\t" . "10% posterior quantile" . "\t" . "posterior mean" . "\t" . "90% posterior quantile" . "\n"; 
while(<IN>) {
    s/[\r\n]//g;
    @curRow = split("\t", $_);
    print join("\t", @curRow[0 .. $#curRow - 7]) . "\t" . join("\t", @curRow[$#curRow - 5  .. $#curRow]) . "\n";
}
close(IN);

