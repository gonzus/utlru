use strict;
use warnings;
use Test::More;

use Cache::utLRU;

my $cache = Cache::utLRU->new();

my %mem;
my $k;
while ($k = <DATA>) {
    chomp $k;
    $cache->add($k, $k);
    $mem{$k} = ${k};
}
my $hits = 0;
$cache->visit(sub { $hits += $mem{$_[0]} eq $_[1] ? 1 : 0 });
is $hits, scalar keys %mem, "all values found";

done_testing;
__DATA__
foo
bar
baz
