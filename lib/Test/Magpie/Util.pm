package Test::Magpie::Util;
# ABSTRACT: Utilities used by Test::Magpie
use strict;
use warnings;

use aliased 'Test::Magpie::ArgumentMatcher';
use Scalar::Util qw( blessed );

use Sub::Exporter -setup => {
    exports => [qw( extract_method_name match )],
};

sub extract_method_name {
    my $name = shift;
    my ($method) = $name =~ qr/:([^:]+)$/;
    return $method;
}

sub match {
    my ($a, $b) = @_;
    return blessed($a)
        ? (ref($a) eq ref($b) && $a == $b)
        : $a ~~ $b;
}

1;

=func extract_method_name

Internal. From a fully qualified method name such as Foo::Bar::baz, will return
just the method name (in this example, baz).

=func match

Internal. Match 2 values for equality

=cut

