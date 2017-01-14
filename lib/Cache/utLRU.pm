package Cache::utLRU;

use strict;
use warnings;

use XSLoader;
our $VERSION = '0.001000';
XSLoader::load(__PACKAGE__, $VERSION);

1;

__END__

=pod

=encoding utf8

=head1 SYNOPSIS

Cache::utLRU - A Perl LRU cache using the uthash library

=head1 DESCRIPTION

Quick & dirty implementation of a Perl LRU cache using the uthash library.

=head1 AUTHORS

=over 4

=item * Gonzalo Diethelm C<< gonzus AT cpan DOT org >>

=back

=head1 THANKS

The C<uthash> team at L<http://troydhanson.github.com/uthash>.
