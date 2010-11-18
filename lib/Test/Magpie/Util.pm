package Test::Magpie::Util;
# ABSTRACT: Utilities used by Test::Magpie
use strict;
use warnings;

use Sub::Exporter -setup => {
    exports => [qw( extract_method_name )],
};

sub extract_method_name {
    my $name = shift;
    my ($method) = $name =~ qr/:([^:]+)$/;
    return $method;
}

1;

=method extract_method_name

Internal. From a fully qualified method name such as Foo::Bar::baz, will return
just the method name (in this example, baz).

=cut

