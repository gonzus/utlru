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

    my $cache = Cache::utLRU->new;

    foreach my $lastname (keys %composers) {
        my $firstname = $composers{$lastname};
        $cache->add($lastname, $firstname);
    }
    foreach my $lastname (keys %composers) {
        my $wanted = $composers{$lastname};
        my $got = $cache->find($lastname);
        is($got, $wanted, "got '$got' for '$lastname'");
    }

    done_testing;
    return 0;
}
