use Test::More;

use Cache::utLRU;

exit main();

sub main {
    my %composers = (
        'Grieg' => 'Edvard',
        'Berlioz' => 'Hector',
        'Debussy' => 'Claude',
        'van Beethoven' => 'Ludwig',
        'Bach' => 'Johann Sebastian',
        'Telemann' => 'George Philippe',
        'Handel' => 'Georg Friedrich',
        'Wagner' => 'Richard',
        'Verdi' => 'Giuseppe',
        'Liszt' => 'Franz',
        'Chopin' => 'Frederic',
        'Tchaikovsky' => 'Piotr Ilich',
    );

    my $size = scalar keys %composers;
    my $cache = Cache::utLRU->new($size);
    is($cache->size, 0, "cache starts life empty");

    foreach my $lastname (keys %composers) {
        my $firstname = $composers{$lastname};
        $cache->add($lastname, $firstname);
    }
    is($cache->size, $size, "cache grows to $size elements");
    foreach my $lastname (keys %composers) {
        my $wanted = $composers{$lastname};
        my $got = $cache->find($lastname);
        is($got, $wanted, "got '$got' for '$lastname'");
    }
    is($cache->size, $size, "cache still has $size elements");

    $cache->clear;
    is($cache->size, 0, "cache ends life empty");

    done_testing;
    return 0;
}
