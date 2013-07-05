package Test::Magpie::Util;
# ABSTRACT: Utilities used by Test::Magpie
use strict;
use warnings;
use 5.010_001; # dependency for smartmatching

use aliased 'Test::Magpie::ArgumentMatcher';
use Scalar::Util qw( blessed );

use Sub::Exporter -setup => {
    exports => [qw( extract_method_name has_caller_package match )],
};

sub extract_method_name {
    my $name = shift;
    my ($method) = $name =~ qr/:([^:]+)$/;
    return $method;
}

sub has_caller_package {
    my $package= shift;

    my $level = 1;
    while (my ($caller) = caller $level++) {
        return 1 if $caller eq $package;
    }
    return;
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

=func has_caller_package($package)

Internal. Returns whether the given C<$package> is in the current call stack.

=func match

Internal. Match 2 values for equality

=cut

